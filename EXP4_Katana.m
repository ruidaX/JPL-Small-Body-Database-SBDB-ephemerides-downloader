% Copied from EXP2, adapted for parallel computing
% 
% 20220724:I think I havent run this on Katana, instead I run this on the school computer remotely


clc
clear all
close all
% 
% PBS_index = str2double(getenv('PBS_ARRAY_INDEX'));
% pack_ID  = PBS_index;

%% load asteroid IDs
asteroid_list_file = "sbdb_query_results_20220503.csv";
table_full = readtable(["./asteroid_list/"+asteroid_list_file]);
spk_list = table_full.spkid;
% spk_list= flipud(spk_list );
% spk_list = spk_list(1:200);


%% pre-define some answers
email = '123@sina.com';
start_date = '2020-01-01';
end_date = '2100-01-01';
spk_format = 'Binary';


%% spk packs
pack_size = 200;
pack_num = floor( length(spk_list)/pack_size ) + ( mod(length(spk_list),pack_size)>0 );
pack_index = zeros(pack_num,2);
pack_index(:,1) = ((1:pack_num)-1)*pack_size+1;
pack_index(:,2) = (1:pack_num)*pack_size;
pack_index(end,2) = length(spk_list);
pack_processing_time = zeros(pack_num,1);


%% set up file save path
file_path_bsp = "./neo_bsp/";
mkdir(file_path_bsp);

err_spk = [];
err_pack_index = [];
err_id_inpack = [];
err_string = [];
%% big loop
for i=1:pack_num
    %% connect to the server
    start_time_pack = tic;

    disp('connecting to Horizons');
    t = tcpclient("ssd.jpl.nasa.gov",6775,"ConnectTimeout",10);
    % configureTerminator(t,"CR/LF");
    disp('connected to Horizons !');
    [answer_real] = messenger_new(t,'','Horizons> ')


    %% first object in this pack
    [answer_real] = messenger_new(t, ['des=' num2str( spk_list(  pack_index(i,1)  ) ) ] ,  'Continue [ <cr>=yes, n=no, ? ] : ')



    [answer_real] = messenger_new(t, 'yes' ,  'Select ... [A]pproaches, [E]phemeris, [F]tp,[M]ail,[R]edisplay, [S]PK,?,<cr>: ')

    if isincludein(answer_real,'Select ... [E]phemeris, [F]tp, [M]ail, [R]edisplay, ?, <cr>: ')
        writeline(t,'-');% check the technote for reasons
        err_spk = [err_spk;  spk_list(  pack_index(i,1)  )  ];
        err_pack_index = [err_pack_index;  i];
        err_id_inpack = [err_id_inpack; 1];
        err_string = [err_string; string(answer_real)];
        continue;
    end


    [answer_real] = messenger_new(t, 'S' ,  'Enter your Internet e-mail address [?]: ')

    [answer_real] = messenger_new(t, email ,  'Confirm e-mail address [yes(<cr>),no] : ')

    [answer_real] = messenger_new(t, 'yes' ,  'SPK file format    [Binary, ASCII, 1, ?] : ')

    [answer_real] = messenger_new(t, spk_format ,  'SPK object START [ t >= 1600-Jan-01, ? ] : ')

    [answer_real] = messenger_new(t, start_date ,  'SPK object STOP  [ t <= 2500-Jan-01, ? ] : ')

    [answer_real] = messenger_new(t, end_date ,  ' Add more objects to file  [ YES, NO, ? ] : ')


    %% following object
    %% if the begin index = end index, then it means this package only include 1 asteroid, else it will enter into a loop to add more asteroid in one spk
    if pack_index(i,1)==pack_index(i,2)

        [ftp_response] = messenger_new(t, 'NO' ,  'Select ... [E]phemeris, [M]ail, [R]edisplay, ?, <cr>: ')

    else

        [answer_real] = messenger_new(t, 'YES' ,  ' Select ... [E]phemeris, [M]ail, [R]edisplay, ?, <cr>: ')
        num_in_pack = 1;
        for j = (pack_index(i,1)+1):pack_index(i,2)

            disp('******************************');
            disp(["PACK:"+num2str(i)+"; NUM:"+num2str(num_in_pack)]);
            disp('******************************');



            [answer_real] = messenger_new(t, ['des=' num2str( spk_list( j ) )  ] , 'Continue [ <cr>=yes, n=no, ? ] : ')

            %%
            [answer_real] = messenger_new(t, 'yes' ,  ' Select ... [A]pproaches, [E]phemeris, [F]tp,[M]ail,[R]edisplay, [S]PK,?,<cr>: ')

            if isincludein(answer_real,'Select ... [E]phemeris, [F]tp, [M]ail, [R]edisplay, ?, <cr>: ')
                writeline(t,'-');% check the technote for reasons
                err_spk = [err_spk; spk_list(  j  )  ];
                err_pack_index = [err_pack_index;  i];
                err_id_inpack = [err_id_inpack; j];
                err_string = [err_string; string(answer_real)];
                continue;
            end



            %             [answer_real] = messenger_new(t, 'yes' ,  ' Select ... [A]pproaches, [E]phemeris, [F]tp,[M]ail,[R]edisplay, [S]PK,?,<cr>: ')
            %%
            [answer_real] = messenger_new(t, 'S' ,  'SPK object START [ t >= 1600-Jan-01, ? ] : ')

            [answer_real] = messenger_new(t, start_date ,  'SPK object STOP  [ t <= 2500-Jan-01, ? ] : ')

            if (j - pack_index(i,1)+1)==200
                % this means we have *tried* to put 200 asteroids in the
                % spk file, but is may not contain 200 asteroids info,
                % because there are asteroids like bennu cannot be added to
                % the spk file in the new system. In this case, the horizon
                % will ask you ' Add more objects to file  [ YES, NO, ? ] :
                % ' instead of generate a ftp link directly.

                % num_in_pack is a sign to check if we skip any asteroids
                % like bennu, because this loop added asteroids from the
                % second index(the first has been added seperatedly above),
                % so if everythings fine, this number should be 199 by now.
                % If it is less than 199, then we have to first answer
                % 'No', then get the ftp link.
                if num_in_pack<199
                    [answer_real] = messenger_new(t, end_date ,  ' Add more objects to file  [ YES, NO, ? ] : ')
                    [ftp_response] = messenger_new(t, 'NO' ,  'Select ... [E]phemeris, [M]ail, [R]edisplay, ?, <cr>: ')

                elseif num_in_pack==199
                    [ftp_response] = messenger_new(t, end_date ,  'Select ... [E]phemeris, [M]ail, [R]edisplay, ?, <cr>: ')
                else
                    error('unknown error')
                end
                break;%break and go to file downloading part

            end

            [answer_real] = messenger_new(t, end_date ,  ' Add more objects to file  [ YES, NO, ? ] : ')

            if j==pack_index(i,2)
                [ftp_response] = messenger_new(t, 'NO' ,  'Select ... [E]phemeris, [M]ail, [R]edisplay, ?, <cr>: ')
            else
                [answer_real] = messenger_new(t, 'YES' ,  'Select ... [E]phemeris, [M]ail, [R]edisplay, ?, <cr>: ')
            end

            num_in_pack = num_in_pack+1;
        end
    end

    %% all options above should lead to one result: an ftp download address
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    example:
    %    You have    10 minutes to retrieve the following by anonymous FTP:
    %    Machine name:  ssd.jpl.nasa.gov
    %    Directory   :  cd to "/pub/ssd/"
    %    File name   :  wld3801.15
    %    File type   :  BINARY   >* set FTP binary mode *<
    %    Full path   :  ftp://ssd.jpl.nasa.gov/pub/ssd/wld3801.15
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %This function is to find ftp link from the reply from HORIZON system
    ftp_str=GetFtpLink(ftp_response)
    %This is to get file name on server, the file only exist for 10 minutes
    %Read the name from end until come across a '/'
    file_name=ftp_str(end);
    for q=1:length(ftp_str)
        if ftp_str(end-q)=='/'
            break;
        end
        file_name=[ftp_str(end-q) file_name];
    end
    ftpobj=ftp('ssd.jpl.nasa.gov');
    cd(ftpobj,'pub/ssd') %cd the path to the file
    mget(ftpobj,file_name);% dowload file
    %   rename the file
    new_file_name=file_path_bsp + "/"+ num2str(pack_index(i,1))+ "-"+  num2str(pack_index(i,2)) +".bsp";
    movefile(file_name, new_file_name)
    fprintf('SPK generation complete! \n');


    end_time_pack = toc(start_time_pack);
    pack_processing_time = end_time_pack;
    

    clear t;

    save(file_path_bsp+"/record-"+ num2str(pack_index(i,1))+ "-"+  num2str(pack_index(i,2))  +".mat",'pack_processing_time');

save(file_path_bsp+"/record-"+ num2str(pack_index(i,1))+ "-"+  num2str(pack_index(i,2))  +".mat",'err_spk','-append');
save(file_path_bsp+"/record-"+ num2str(pack_index(i,1))+ "-"+  num2str(pack_index(i,2))  +".mat", 'err_pack_index','-append');
save(file_path_bsp+"/record-"+ num2str(pack_index(i,1))+ "-"+  num2str(pack_index(i,2))  +".mat",'err_id_inpack','-append');
save(file_path_bsp+"/record-"+ num2str(pack_index(i,1))+ "-"+  num2str(pack_index(i,2))  +".mat",'err_string','-append');




end


%% save some more data




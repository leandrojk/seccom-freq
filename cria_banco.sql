connect 'jdbc:derby://localhost:1300/BD_SECCOM_FREQ;create=true;user=usuario1';
call syscs_util.syscs_create_user('usuario1','senha1');

create table SEMANA(
    ANO int not null,
    NOME varchar(200) not null,
    TEMA varchar(200) not null,
    primary key (ANO)
);

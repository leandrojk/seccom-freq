connect 'jdbc:derby://localhost:1300/BD_SECCOM_FREQ;user=usuario1;password=senha1';

drop table USUARIO;
drop table PRESENCA;
drop table ESTUDANTE;
drop table PALESTRA;
drop table SEMANA;

create table USUARIO(
    LOGIN varchar(20) not null,
    NOME varchar(100) not null,
    SENHA varchar(100) not null,
    ADM BOOLEAN not null,
    primary key (LOGIN)
);

create table SEMANA(
    ANO int not null,
    NOME varchar(200) not null,
    TEMA varchar(200) not null,
    primary key (ANO)
);

create table PALESTRA(
  ID int not null generated always as identity,
  SEMANA_ANO int not null,
  TITULO varchar(200) not null,
  PALESTRANTE varchar(200) not null,
  DIA date not null,
  HORARIODEINICIO time not null,
  HORARIODETERMINO time not null,
  primary key (ID),
  constraint ano_fk  foreign key (SEMANA_ANO) references SEMANA(ANO)
);

create table ESTUDANTE(
    MATRICULA int not null,
    NOME varchar(100) not null,
    primary key (MATRICULA)
);

create table PRESENCA(
    ESTUDANTE_MATRICULA int not null,
    PALESTRA_ID int not null,
    primary key (ESTUDANTE_MATRICULA, PALESTRA_ID),
    constraint matricula_fk foreign key (ESTUDANTE_MATRICULA) references ESTUDANTE(MATRICULA),
    constraint palestra_fk foreign key (PALESTRA_ID) references PALESTRA(ID)
);
connect 'jdbc:derby://localhost:1300/BD_SECCOM_FREQ;user=usuario1;password=senha1';

drop table PALESTRA;
drop table SEMANA;

create table SEMANA(
    ANO int not null,
    NOME varchar(200) not null,
    TEMA varchar(200) not null,
    primary key (ANO)
);

create table PALESTRA(
  ID int not null generated always as identity,
  ANO int not null,
  TITULO varchar(200) not null,
  PALESTRANTE varchar(200) not null,
  DIA date not null,
  HORARIODEINICIO time not null,
  HORARIODETERMINO time not null,
  primary key (ID),
  constraint ano_fk  foreign key (ANO) references SEMANA(ANO)
);

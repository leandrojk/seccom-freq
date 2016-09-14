connect 'jdbc:derby://localhost:1300/BD_SECCOM_FREQ;user=usuario1;password=senha1';

delete from USUARIO;
delete from PRESENCA;
delete from ESTUDANTE;
delete from PALESTRA;
delete from SEMANA;

insert into USUARIO values ('fulano', 'Fulano de Tal', 'x9', true);

insert into SEMANA values (2016, 'SECCOM 2016', 'O ano da IoT');

insert into PALESTRA (SEMANA_ANO,TITULO,PALESTRANTE,DIA,HORARIODEINICIO,HORARIODETERMINO) values 
(2016,'As novas formas de programar', 'Dr. Barba Rala', '2016-10-15', '08:00', '09:30'),
(2016,'Transformando bits em dinheiro', 'Prof. Adroaldo Gaita Alta', '2016-10-16', '14:30', '14:45');

insert into ESTUDANTE values(1010, 'Marcelo Dez Dez');



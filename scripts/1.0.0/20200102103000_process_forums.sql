insert into settings (key, value) values ('process.forums', 't');
delete from settings where key = 'process.forum';
commit;

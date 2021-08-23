insert into settings (key, value) values ('homepage.widgets.feeds.city_hall_proposals', 't');
insert into settings (key, value) values ('homepage.widgets.feeds.citizen_proposals', 't');
insert into settings (key, value) values ('last_citizens_official_level', '1');
commit;

INSERT INTO widget_feeds (kind, "limit", created_at, updated_at) VALUES('city_hall_proposals', 1, now(), now());
INSERT INTO widget_feeds (kind, "limit", created_at, updated_at) VALUES('citizen_proposals', 1, now(), now());
DELETE FROM widget_feeds WHERE kind IN('proposals', 'debates');
commit;

UPDATE settings SET value = 'Empleados públicos' WHERE key = 'official_level_1_name';
UPDATE settings SET value = 'Organización Municipal' WHERE key = 'official_level_2_name';
UPDATE settings SET value = 'Directivos' WHERE key = 'official_level_3_name';
UPDATE settings SET value = 'Concejales' WHERE key = 'official_level_4_name';
UPDATE settings SET value = 'Alcalde' WHERE key = 'official_level_5_name';
UPDATE settings SET value = 'CONSUL' WHERE key = "facebook_handle";
UPDATE settings SET value = 'CONSUL' WHERE key = "instagram_handle";
UPDATE settings SET value = '@consul_dev' WHERE key = "twitter_handle";
UPDATE settings SET value = '#consul_dev' WHERE key = "twitter_hashtag";
UPDATE settings SET value = 'CONSUL' WHERE key = "youtube_handle";
UPDATE settings SET value = 'Santander SmartCitizen' WHERE key = "org_name";
commit;

SET FOREIGN_KEY_CHECKS=0;
UPDATE `bss_sub_role` SET role_id = 0 WHERE role_name='admin';
UPDATE `customer_group` SET customer_group_id = 0 WHERE customer_group_code='NOT LOGGED IN';
UPDATE `store` SET store_id = 0 WHERE CODE='admin';
UPDATE `store_group` SET group_id = 0 WHERE NAME='Default';
UPDATE `store_website` SET website_id = 0 WHERE CODE='admin';
SET FOREIGN_KEY_CHECKS=1;
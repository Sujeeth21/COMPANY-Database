/*
ER DIAGRAM FOR DB_SECURITY ASSUMPTIONS VS IMPLEMENTATION:
1) USER_PRIVILEGES entity has all the privileges that a user can have and the priv_type attribute will classify the
privileges into account_privileges and relational_privileges.
2) The ROLE_PRIVILEDGES entity maps user roles to their respective priviledges.

 

USER_ACCOUNT:      Maintains record of all the users, their roles and id's of users who granted them.
USER_ROLES:        Maintains records of all roles with their id(auto_increment) and descriptions.
USER_PRIVILEGES:   Maintains all the privileges.Has id(auto_increment), descriptions and type. 
                   The type is an enum field. 
                   Can be either account_privilege or relational_privilege(though needless).
TABLES:            The name of the entity is TABLES. The auto_increment attribute id is primary key, 
                   that uniquely identifies the records of the entity.
                   Also maintains rcords of user who created it and the timestamp of creation.
ROLE_PRIVILEGES:   The attribute id is a composite key.
                   (role_id,privileges_id) identifies each record uniquely.
                   Used for performing join on other columns.
                   
ACCESS_LEVEL_IDENTIFIER: This entity maps role_id + privileges_id to various entities. 
                    We have three roles defined: Manager,Developer and Tester.
                    If the user role is developer, it will have access to table XYZ to SELECT,CREATE,DELETE,UPDATE,DROP,INSERT. 
                    The role_priv_id(composite for role_id and privileges_id) = 2 and 
                    table_id = 3(for eg entity PRODUCTS in real world) will be holding the data records.
                    Similarly Manager role is identified by role_id 1 and Tester by 3

 

 

 

* ACCESS_LEVEL_IDENTIFIER entity to identify a method to map the roles that have/has access to either of privileges.
(CREATE,DROP,UPDATE,INSERT etc)
    

 

 

 

*/

 

 
create schema DB_SECURITY;
use DB_SECURITY;
SET FOREIGN_KEY_CHECKS=0;

 
create table USER_ACCOUNT(
id int auto_increment,
fname varchar(50) not null,
mname char(5) not null,
lname varchar(50) not null,
email varchar(50),
role_id int,
grant_by int,
primary key(id),
key(role_id),
constraint GRANTBYFK foreign key(grant_by) references user_account(id),
constraint USERROLEIDFK foreign key(role_id) references user_roles(id)
); 
 
 Truncate table USER_ACCOUNT;

INSERT INTO USER_ACCOUNT(fname,mname,lname,email,role_id,grant_by) VALUES
('Tom', 'M', 'Hawkins', 'tomhawkins@gmail.com', '1', '1');

INSERT INTO USER_ACCOUNT(fname,mname,lname,email,role_id,grant_by) VALUES
('Nancy', 'C', 'Grey', 'nancygrey@gmail.com', '2', '2');

select * from USER_ACCOUNT;
 
 
create table USER_ROLES(
id int auto_increment,
role_desc varchar(20),
primary key(id)
);

Truncate table USER_ROLES;

INSERT INTO USER_ROLES(role_desc) VALUES
('Manager');

INSERT INTO USER_ROLES(role_desc) VALUES
('Developer');

INSERT INTO USER_ROLES(role_desc) VALUES
('Tester');

select * from USER_ROLES; 

create table USER_PRIVILEGES(
id int auto_increment,
priv_desc varchar(20),
priv_type enum("account_privileges", "relational_privileges"),
primary key(id)
);


Truncate table USER_PRIVILEGES;

INSERT INTO USER_PRIVILEGES(priv_desc,priv_type) VALUES
('Select','Relational_privileges'),
('Insert','Relational_privileges'),
('Update','Relational_privileges'),
('Delete','Relational_privileges'),
('Create','Account_privileges'),
('Drop','Account_privileges'),
('Alter','Account_privileges');

select * from user_privileges;

create table `TABLES`(
id int auto_increment,
tname varchar(100),
created_on datetime default now(),
created_by int,
primary key(id),
unique key(tname),
constraint CREATEDBYFK foreign key(created_by) references USER_ACCOUNT(id)
);


insert into tables (tname,created_by) values ('products','1');

insert into tables (tname,created_by) values ('TAB2','2');

 select * from tables;
 

create table ROLE_PRIVILEGES(
id int auto_increment,
role_id int,
privileges_id int,
primary key(id),
unique key(role_id,privileges_id),
constraint ROLEPRIVIDFK foreign key(role_id) references user_roles(id),
constraint PRIVILEGEIDFK foreign key(privileges_id) references USER_PRIVILEGES(id)
);


Truncate table ROLE_PRIVILEGES;
 
INSERT INTO ROLE_PRIVILEGES(role_id,privileges_id) VALUES
('1','1');
INSERT INTO ROLE_PRIVILEGES(role_id,privileges_id) VALUES
('1','2');
INSERT INTO ROLE_PRIVILEGES(role_id,privileges_id) VALUES
('1','3');
INSERT INTO ROLE_PRIVILEGES(role_id,privileges_id) VALUES
('1','4');
INSERT INTO ROLE_PRIVILEGES(role_id,privileges_id) VALUES
('1','5');
INSERT INTO ROLE_PRIVILEGES(role_id,privileges_id) VALUES
('1','6');
INSERT INTO ROLE_PRIVILEGES(role_id,privileges_id) VALUES
('1','7');

INSERT INTO ROLE_PRIVILEGES(role_id,privileges_id) VALUES
('2','1'),('2','2'),('2','3'),('2','4');

INSERT INTO ROLE_PRIVILEGES(role_id,privileges_id) VALUES
('3','1');

select * from ROLE_PRIVILEGES;
 


create table ACCESS_LEVEL_IDENTIFIER(
table_id int,
role_priv_id int,
primary key(table_id, role_priv_id),
constraint TABLEIDFK foreign key(table_id) references `TABLES`(id),
constraint ROLEPRIVID foreign key(role_priv_id) references ROLE_PRIVILEGES(id)
);
 
 Truncate table ROLE_PRIVILEGES;
 
INSERT INTO ACCESS_LEVEL_IDENTIFIER(table_id,role_priv_id) VALUES
('1','1');
INSERT INTO ACCESS_LEVEL_IDENTIFIER(table_id,role_priv_id) VALUES
('2','2');
  
 select * from ACCESS_LEVEL_IDENTIFIER;
  
 insert into ACCESS_LEVEL_IDENTIFIER

/*Q5*/
Select USER_ACCOUNT.id as 'User Account', USER_ROLES.role_desc as 'Role'
FROM USER_ACCOUNT join USER_ROLES on USER_ACCOUNT.role_id=USER_ROLES.id 
where USER_ROLES.role_desc='Manager';

/*Q.6*/

select user_privileges.priv_type as 'Type', user_privileges.priv_desc as 'Privilege', USER_ROLES.role_desc as 'Role' 
from user_privileges join ROLE_PRIVILEGES on user_privileges.id=ROLE_PRIVILEGES.privileges_id join USER_ROLES 
on ROLE_PRIVILEGES.role_id = USER_ROLES.id
where USER_ROLES.role_desc = 'Manager';


/*Q.7*/
select tab.id as table_id, role_priv.id as role_priv_id
from `TABLES` tab
join ROLE_PRIVILEGES role_priv
join USER_ROLES user_role on user_role.id = role_priv.role_id
where user_role.role_desc = 'manager';


 select * from ACCESS_LEVEL_IDENTIFIER;
 
drop temporary table if exists user_tables;
create temporary table user_tables
select id as table_id from TABLES where tname in("USER_ACCOUNT","USER_ROLES", "USER_PRIVILEGES", "TABLES", "ROLE_PRIVILEGES", "ACCESS_LEVEL_IDENTIFIER")
;


-- A Developer role has All relational privileges on PRODUCTS,CUSTOMER and PAYMENTS table but only
-- SELECT privilege on user_account and privileges tables( as mapped in user_tables temp table).
insert into ACCESS_LEVEL_IDENTIFIER
select tab.id as table_id, role_priv.id as role_priv_id -- , tab.tname,priv.priv_type
from `TABLES` tab
left join user_tables ut on tab.id = ut.table_id
join ROLE_PRIVILEGES role_priv
join USER_ROLES ur on ur.id = role_priv.role_id
join USER_PRIVILEGES priv on priv.id = role_priv.privileges_id
where ur.role_desc = "developer"
and if(ut.table_id is null, True, priv.id=1);
 
 -- A Tester role has no access or privileges on user_account or
-- privileges related tables(as mapped in user_tables temp table)
-- and only has SELECT access on other tables like Products,Customer,PAYMENTS etc
insert into ACCESS_LEVEL_IDENTIFIER
select tab.id as table_id, role_priv.id as role_priv_id -- , tab.tname,priv.priv_type
from `TABLES` tab
left join user_tables ut on tab.id = ut.table_id
join ROLE_PRIVILEGES role_priv
join USER_ROLES ur on ur.id = role_priv.role_id
join USER_PRIVILEGES priv on priv.id = role_priv.privileges_id
where ur.ROLE_DESC = "tester"
and ut.table_id is null
and priv.id=1
;

select tab.id as table_id, tab.tname as 'Table Name', ur.role_desc as roleName, role_priv.id as role_priv_id, priv.priv_type as privilege_type, priv.priv_desc
from `TABLES` tab
left join tables ut on tab.id = ut.id
join ROLE_PRIVILEGES role_priv
join USER_ROLES ur on ur.id = role_priv.role_id
join USER_PRIVILEGES priv on priv.id = role_priv.privileges_id
where tab.tname = "products";

select tab.id as table_id, tab.tname as 'Table Name', ur.role_desc as roleName, role_priv.id as role_priv_id, priv.priv_type as privilege_type, priv.priv_desc
from `TABLES` tab
left join user_tables ut on tab.id = ut.table_id
join ROLE_PRIVILEGES role_priv
join USER_ROLES ur on ur.id = role_priv.role_id
join USER_PRIVILEGES priv on priv.id = role_priv.privileges_id
where tab.tname = "TAB3";
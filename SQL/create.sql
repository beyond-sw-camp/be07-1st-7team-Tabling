
use tabling;


CREATE TABLE `user` (
`id` BigInt primary key auto_increment,
`name` varchar(50) NOT NULL,
`author_yn` ENUM('Y','N') NOT NULL,
`nickname` varchar(50)unique NOT NULL,
`email` varchar(50) unique NOT NULL,
`phone` varchar(15) unique NOT NULL,
`password` varchar(20),
`locate_service_agmt` enum('Y','N') NOT NULL default 'N',
`service_use_agmt` enum('Y','N') NOT NULL default 'N',
`info_privacy_policy_agmt` enum('Y','N') NOT NULL NULL default 'N',
`marketing_agmt` enum('Y','N') NOT NULL NULL default 'N',
`push_notice_use_agmt` enum('Y','N') NOT NULL NULL default 'N',
`notice_agmt` enum('Y','N') NOT NULL NULL default 'N',
`created_time` datetime NOT NULL default current_timestamp,
`updated_time` datetime NOT NULL default current_timestamp
);


CREATE TABLE `store` (
`id` BigInt primary key auto_increment,
`address_do`varchar(15) NULL,
`address_si`varchar(15)NOT NULL,
`address_gu`varchar(15)NOT NULL,
`detail_address`varchar(50)NOT NULL,
 location POINT NOT NULL,
`remote_tabling`enum('Y','N') NOT NULL default 'Y',
`onsite_tabling`enum('Y','N') NOT NULL default 'Y',
`name`varchar(50) unique not null ,
`phone`varchar(50) not null,
`status`enum('영업중','폐점','휴점') not null default '영업중',
`ratings`decimal(3,2) default 0,
`review_cnt`BigInt not null default 0,
`description`varchar(255) NULL,
`created_time` datetime NOT NULL default current_timestamp,
`updated_time` datetime NOT NULL default current_timestamp,
SPATIAL INDEX(location)
);

-- 
CREATE TABLE `user_oauth` (
`id` BigInt primary key auto_increment,
`user_id`BigInt NOT NULL,
`token`varchar(100) NOT NULL,
`company` enum('네이버','카카오', '애플', '페이스북', '구글') NOT NULL,
    foreign key (user_id) references user(id) on update cascade
);


CREATE TABLE `group` (
`id` BigInt primary key auto_increment,
`name`varchar(255) unique NOT NULL,
`created_time`datetime default current_timestamp,
`detail`varchar(255) NULL,
`profile_Img`varchar(255) NULL
);

CREATE TABLE `user_group` (
`id` BigInt primary key auto_increment,
`user_id`BigInt NOT NULL,
`group_id`BigInt NOT NULL,
    foreign key (user_id) references user(id) on update cascade on delete cascade,
    foreign key (group_id) references `group`(id) on update cascade
);

CREATE TABLE store_image(
	id bigint auto_increment primary key,
    store_id bigint not null,
    image_path varchar(100),
    created_at datetime default current_timestamp,
    updated_at datetime,
    foreign key (store_id) references store(id) on update cascade
);

CREATE TABLE wishlist(
	id bigint auto_increment primary key,
    user_id bigint not null,
    store_id bigint not null,
    created_time datetime default current_timestamp,
	`updated_time` datetime default current_timestamp,
    foreign key (user_id) references user(id) on update cascade,
    foreign key (store_id) references store(id) on update cascade
);

CREATE TABLE store_open_end_break(
	id bigint auto_increment primary key,
    store_id bigint not null,
    days enum('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'),
    start time,
    end time,
    break_start time,
    break_end time,
    foreign key (store_id) references store(id) on update cascade
);


CREATE TABLE category(
	id bigint auto_increment primary key,
	content varchar(255),
    category_name varchar(255) NOT NULL
);

CREATE TABLE store_category(
	store_id bigint not null,
    category_id bigint not null,
    foreign key (store_id) references store(id) on update cascade on delete cascade,
    foreign key (category_id) references category(id) on update cascade on delete cascade
);

CREATE TABLE reservation(
	id bigint auto_increment primary key,
    store_id bigint not null,
    user_id bigint not null,
    group_id bigint null,
    status enum('예약중','완료','취소') default '예약중',
    created_time datetime default current_timestamp,
    num int not null,
    reserve_date date not null, -- '2023-06-03 14:00:00'
    reviewYN enum('Y','N') default 'N',
    gr_id bigint,
    foreign key (store_id) references store(id) on update cascade,
    foreign key (user_id) references user(id) on update cascade,
    foreign key (group_id) references `group`(id) on update cascade
);

CREATE TABLE waiting(
	id bigint auto_increment primary key,
    store_id bigint not null,
    user_id bigint not null,
    group_id bigint null,
    status enum('대기중','완료','취소') default '대기중',
    created_time datetime default current_timestamp,
    update_time datetime,
    foreign key (store_id) references store(id) on update cascade,
    foreign key (user_id) references user(id) on update cascade,
    foreign key (group_id) references `group`(id) on update cascade
);

CREATE TABLE `menu_category` (
`id` BIGINT auto_increment,
`store_id` BIGINT NOT NULL,
`name` varchar(50) NOT NULL,
`discription` VARCHAR(100),
    PRIMARY KEY (`id`),
    FOREIGN KEY (`store_id`) REFERENCES `store` (`id`) on delete cascade on update cascade
);

CREATE TABLE `menu_title` (
`id` BIGINT auto_increment,
`menu_category_id` BIGINT NOT NULL,
`name` varchar(50) NOT NULL,
`price` decimal NOT NULL,
`discription` varchar(100),
    PRIMARY KEY (`id`),
    FOREIGN KEY (`menu_category_id`) REFERENCES `menu_category` (`id`) on delete cascade on update cascade
);


CREATE TABLE `posting` (
id BIGINT auto_increment,
user_id BIGINT,
store_id BIGINT,
title varchar(50) NOT NULL,
content varchar(1000)NOT NULL,
created_time datetime NULL DEFAULT current_timestamp,
`updated_time` datetime DEFAULT current_timestamp,
PRIMARY KEY (id),
FOREIGN KEY (user_id) REFERENCES user(id) on delete set null on update cascade,
FOREIGN KEY (store_id) REFERENCES store(id) on delete set null on update cascade
);

CREATE TABLE `posting_comments` (
id BIGINT auto_increment,
`posting_id` BIGINT NOT NULL,
`user_id` BIGINT ,
`title` varchar(50) NOT NULL,
`content` varchar(255) NOT NULL,
`created_time`datetime NULL DEFAULT current_timestamp,
`updated_time` datetime DEFAULT current_timestamp,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) on delete set null on update cascade,
    FOREIGN KEY (`posting_id`) REFERENCES `posting` (`id`) on delete cascade on update cascade
);

CREATE TABLE posting_image (
    id BIGINT auto_increment,
    posting_id  BIGINT NOT NULL,
    image_url varchar(255) null,
    PRIMARY KEY (id),
FOREIGN KEY (`posting_id`) REFERENCES `posting` (`id`) on delete cascade on update cascade
);

CREATE TABLE review ( 
id bigint auto_increment primary key, 
store_id BigInt NOT NULL, 
user_id BigInt NOT NULL, 
title varchar(50), 
content varchar(50) NOT NULL,
rating Decimal NOT NULL,
helpful BigInt NULL,
foreign key (store_id) references store(id) on update cascade,
foreign key (user_id) references user(id) on update cascade,
created_time datetime NULL DEFAULT current_timestamp,
`updated_time` datetime DEFAULT current_timestamp);

CREATE TABLE review_image (
id BigInt auto_increment primary key, 
review_id BigInt NOT NULL,
store_id BigInt NOT NULL,
user_id BigInt NOT NULL, 
image_url varchar(255) NULL,
foreign key (review_id) references review(id) on update cascade,
foreign key (store_id) references store(id) on update cascade,
foreign key (user_id) references user(id) on update cascade,
created_time datetime NULL DEFAULT current_timestamp,
`updated_time` datetime DEFAULT current_timestamp);

CREATE TABLE announcement (
announcement_Id BIGINT NOT NULL auto_increment primary key,
title VARCHAR(255) NOT NULL,
content VARCHAR(3000) NOT NULL,
created_time datetime NULL DEFAULT current_timestamp,
`updated_time` datetime DEFAULT current_timestamp);



show tables;

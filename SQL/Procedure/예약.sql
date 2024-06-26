-- 1. 지역별 매장 리스트 조회
DELIMITER //
CREATE PROCEDURE 지역별매장리스트조회(in do varchar(50), in si varchar(50), in gu varchar(50))
BEGIN
    IF gu !='' then
        select s.address_do, s.address_si, s.name, s.ratings, s.remote_tabling, s.onsite_tabling, so.days, si.image_path
		from (store s join store_open_end_break so on s.id=so.store_id) left join store_image si on s.id = si.store_id
        where so.start <= TIME(NOW()) and  TIME(NOW())<= ifnull(break_start,'23:59:59')
        or ifnull(break_end,'00:00:00') <= TIME(NOW()) and TIME(NOW()) < so.end
        and s.address_gu=gu
		and so.days = DAYNAME(NOW());
    ELSEIF si !='' then
        select s.address_do, s.address_si, s.name, s.ratings, s.remote_tabling, s.onsite_tabling, so.days, si.image_path
		from (store s join store_open_end_break so on s.id=so.store_id) left join store_image si on s.id = si.store_id
        where (so.start <= TIME(NOW()) and  TIME(NOW())<= ifnull(break_start,'23:59:59')or ifnull(break_end,'00:00:00') <= TIME(NOW()) and TIME(NOW()) < so.end)
        and s.address_si=si
        and so.days = DAYNAME(NOW());
	ELSEIF do != '' then
        select s.address_do, s.address_si, s.name, s.ratings, s.remote_tabling, s.onsite_tabling, so.days, si.image_path
		from (store s join store_open_end_break so on s.id=so.store_id) left join store_image si on s.id = si.store_id
        where (so.start <= TIME(NOW()) and  TIME(NOW())<= ifnull(break_start,'23:59:59')or ifnull(break_end,'00:00:00') <= TIME(NOW()) and TIME(NOW()) < so.end)
        and s.address_do = do
        and so.days = DAYNAME(NOW());
    else
        select s.address_do, s.address_si, s.name, s.ratings, s.remote_tabling, s.onsite_tabling, so.days, si.image_path
		from (store s join store_open_end_break so on s.id=so.store_id) left join store_image si on s.id = si.store_id
        where (so.start <= TIME(NOW()) and  TIME(NOW())<= ifnull(break_start,'23:59:59')or ifnull(break_end,'00:00:00') <= TIME(NOW()) and TIME(NOW()) < so.end)
		and so.days = DAYNAME(NOW());
    end if;
END
// DELIMITER ;
-- 2. 카테고리별 매장 리스트 조회
-- DELIMITER //
-- CREATE PROCEDURE 카테고리매장리스트조회(in name varchar(50), in val varchar(60))
-- BEGIN
--     IF name IS not NULL THEN -- name ,val
--         select s.name, s.ratings, s.remote_tabling, s.onsite_tabling, si.image_path
-- 		from (store s join store_open_end_break so on s.id=so.store_id) left join store_image si on s.id = si.store_id, category c, store_category sc
-- 		and so.start <= TIME(NOW()) and TIME(NOW())<= ifnull(break_start,'23:59:59') and ifnull(break_end,'00:00:00') <= TIME(NOW()) and TIME(NOW()) <= so.end
-- 		and c.category_name = name and content = val
-- 		and so.days = DAYNAME(NOW());
--     ELSEif val is not null then -- val
--         select s.name, s.ratings, s.remote_tabling, s.onsite_tabling, si.image_path
-- 		from store s, store_open_end_break so,store_image si, category c, store_category sc
-- 		where s.id = so.store_id and s.id = si.store_id and s.id=sc.store_id and c.id=sc.category_id
-- 		and so.start <= TIME(NOW()) and TIME(NOW())<= ifnull(break_start,'23:59:59') and ifnull(break_end,'00:00:00') <= TIME(NOW()) and TIME(NOW()) <= so.end
-- 		and content = val
-- 		and so.days = DAYNAME(NOW());
-- 	else -- 전체
-- 		select s.name, s.ratings, s.remote_tabling, s.onsite_tabling, si.image_path
-- 		from store s, store_open_end_break so,store_image si, category c, store_category sc
-- 		where s.id = so.store_id and s.id = si.store_id and s.id=sc.store_id and c.id=sc.category_id
-- 		and so.start <= TIME(NOW()) and TIME(NOW())<= ifnull(break_start,'23:59:59') and ifnull(break_end,'00:00:00') <= TIME(NOW()) and TIME(NOW()) <= so.end
-- 		and so.days = DAYNAME(NOW());
--     END IF;
-- END
-- // DELIMITER ;
-- 3. 리뷰 생성
DELIMITER //
CREATE PROCEDURE 리뷰작성(in user_email varchar(50), in 별점 float, in 타이틀 varchar(60), in 내용 varchar(100), in 이미지경로 varchar(100))
BEGIN
	declare sid int;
    declare rid int;
    declare userid int;
    select id into userid from user where email=user_email;
    select id,store_id into rid,sid from reservation where user_id = userid and `status`='완료' and reviewYN = 'N' limit 1;
	insert into review(store_id, user_id, title, content, rating) values (sid, userid, 타이틀,내용,별점);
    if 이미지경로 is not null then
		INSERT INTO review_image (review_id, store_id, user_id, image_url) 
		VALUES 
		(LAST_INSERT_ID(), sid, userid, 이미지경로);
	end if;
    update reservation set reviewYN='Y' where id = rid;
END
// DELIMITER ;

-- 4. 예약 생성
-- 개인
DELIMITER //
CREATE PROCEDURE 개인_예약생성(in 매장명 varchar(50), in 이메일 varchar(100), in 인원 int, in 예약일시 datetime)
BEGIN
	declare sid int;
    declare uid int;
    select id into sid from store where name = 매장명;
    select id into uid from user where email=이메일;
    INSERT INTO `reservation` (store_id, user_id, num, reserve_date)
	VALUES (sid,uid,인원,예약일시);
END
// DELIMITER ;
-- 그룹
DELIMITER //
CREATE PROCEDURE 그룹_예약생성(in 매장명 varchar(50), in 그룹명 varchar(255), in 인원 int, in 예약일시 datetime)
BEGIN
	declare sid int;
    declare gid int;
    declare rid int;
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE current_id INT;
	DECLARE data_cursor CURSOR FOR select user_id from user_group where group_id=gid;
    
    select id into sid from store where name=매장명;
    select id into gid from `group` where name=그룹명;
	INSERT INTO reservation(store_id,group_id,num,reserve_date) VALUES (sid,gid,인원,예약일시);
    set rid=LAST_INSERT_ID();
    
    OPEN data_cursor;
    data_loop: LOOP
        FETCH data_cursor INTO current_id;
        IF done THEN
            LEAVE data_loop;
        END IF;
        INSERT INTO reservation(store_id, user_id, gr_id, num, reserve_date) VALUES (sid,current_id, rid, 인원, 예약일시);
    END LOOP;
    CLOSE data_cursor;
END
// DELIMITER ;
-- 5. 예약 리스트 조회
-- 개인
DELIMITER //
CREATE PROCEDURE 개인_예약리스트조회(in 이메일 varchar(100))
BEGIN
	declare uid int;
    select id into uid from user where email=이메일; 
    SELECT r.store_id, s.name, r.status, r.num, r.reserve_date
	from reservation r join store s on r.store_id = s.id;
END
// DELIMITER ;
select * from reservation;
-- 그룹
DELIMITER //
CREATE PROCEDURE 그룹_예약리스트조회(in 그룹명 varchar(100))
BEGIN
	declare gid int;
    select id into gid from `group` where name=그룹명; 
    SELECT r.store_id, s.name, r.num, r.reserve_date
	from reservation r join store s on r.store_id = s.id
	WHERE r.status = '예약중' and r.group_id = gid and reserve_date > now();
END
// DELIMITER ;

-- 6. 방문 완료, 취소 버튼
-- 개인
DELIMITER //
CREATE PROCEDURE 개인_방문완료버튼(in 이메일 varchar(100))
BEGIN
	declare rid int;
    select id into rid from reservation where user_id=(select id from user where email=이메일) and status = '예약중' limit 1;
    update reservation set status='완료' where id = rid;
END
// DELIMITER ;
DELIMITER //
CREATE PROCEDURE 개인_방문취소버튼(in 이메일 varchar(100))
BEGIN
	declare rid int;
    select id into rid from reservation where user_id=(select id from user where email=이메일) and status = '예약중' limit 1;
    update reservation set status='취소' where id = rid;
END
// DELIMITER ;
-- 그룹
DELIMITER //
CREATE PROCEDURE 그룹_방문완료버튼(in 그룹명 varchar(100))
BEGIN
	declare rid int;
    select id into rid from reservation where group_id=(select id from `group` where name=그룹명) and status = '예약중' limit 1;
    update reservation set status='완료' where id = rid;
    update reservation set status='완료' where gr_id=rid;
END
// DELIMITER ;
DELIMITER //
CREATE PROCEDURE 그룹_방문취소버튼(in 그룹명 varchar(100))
BEGIN
	declare rid int;
    select id into rid from reservation where group_id=(select id from `group` where name=그룹명) and status = '예약중' limit 1;
    update reservation set status='취소' where id = rid;
    update reservation set status='취소' where gr_id=rid;
END
// DELIMITER ;
DELIMITER //
CREATE PROCEDURE 가게생성(in 도 varchar(15),in 시 varchar(15),in 구 varchar(15),in 상세주소 varchar(15),in 경도 double,in 위도 double,in 원격대기YN varchar(15),in 현장대기YN varchar(15),in 매장명 varchar(15),in 전화번호 varchar(20))
BEGIN
	INSERT INTO `store`
	(`address_do`,`address_si`,`address_gu`,`detail_address`,`location`,`remote_tabling`,`onsite_tabling`,`name`,`phone`)
	VALUES (도,시,구,상세주소, point(경도, 위도),원격대기YN,현장대기YN,매장명,전화번호);
END
// DELIMITER ;
DELIMITER //
CREATE PROCEDURE 그룹생성(in 그룹명 varchar(15),in 상세설명 varchar(15),in 이미지 varchar(15))
BEGIN
	INSERT INTO `group`
	(name, detail, profile_Img)
	VALUES (그룹명, 상세설명, 이미지);
END
// DELIMITER ;
DELIMITER //
CREATE PROCEDURE 그룹가입(in 유저이메일 varchar(100),in 그룹명 varchar(100))
BEGIN
	declare uid int;
	declare gid int;
    
	select id into uid from user where email=유저이메일;
	select id into gid from `group` where name=그룹명;
    
	INSERT INTO `user_group`
	(user_id, group_id)
	VALUES (uid,gid);
    
END
// DELIMITER ;

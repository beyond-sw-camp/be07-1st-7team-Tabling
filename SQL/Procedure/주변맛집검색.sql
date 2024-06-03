-- 주변 맛집 검색
DELIMITER //
CREATE PROCEDURE 주변맛집검색(in 경도 decimal(7,4),in 위도 decimal(7,4),in 반경 int)
BEGIN
    SET @lat = 위도; 
    SET @lon = 경도; 
    SET @radius = 반경; 
    SELECT name, address_si, address_gu, detail_address, phone,
       round(ST_Distance_Sphere(location, POINT(@lon, @lat)),0) AS distance
    FROM store
    WHERE ST_Distance_Sphere(location, POINT(@lon, @lat)) <= @radius
    ORDER BY distance;
END //
DELIMITER ;
-- 프로시저 호출
CALL 주변맛집검색(126.9276,37.4972,300);

-- 음식점저장
DELIMITER //
CREATE PROCEDURE 음식점저장(in 사용자id bigint,in 음식점id bigint)
BEGIN
    insert into wishlist(user_id,store_id) 
    values(사용자id,음식점id);
END //
DELIMITER ;
-- 프로시저 호출
CALL 음식점저장(사용자id,음식점id);

-- 관심매장조회
DELIMITER //
CREATE PROCEDURE 관심매장조회(in 사용자id BIGINT)
BEGIN
    select name, address_si, address_gu, detail_address, phone
    from wishlist w inner join store s on w.store_id = s.id
    where w.user_id = 사용자id;
END //
DELIMITER ;
-- 프로시저 호출
CALL 관심매장조회(사용자id);

-- 포스팅조회
DELIMITER //
CREATE PROCEDURE 포스팅조회()
BEGIN
    select u.name as 사용자이름, s.name as 가게이름, title, content,photo_url
    from posting p, user u, store s
    where p.user_id = u.id and p.store_id = s.id;
END //
DELIMITER ;
-- 프로시저 호출
CALL 포스팅조회();

-- 포스팅댓글조회
DELIMITER //
CREATE PROCEDURE 포스팅댓글조회(in 포스팅id BIGINT)
BEGIN
    select name, title, content
    from user u inner join posting_comments c on u.id = c.user_id
    where posting_id = 포스팅id;
END //
DELIMITER ;
-- 프로시저 호출
CALL 포스팅댓글조회(포스팅id);
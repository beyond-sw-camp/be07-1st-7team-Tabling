-- 포스팅생성
DELIMITER //
CREATE PROCEDURE 포스팅생성(in 사용자id BIGINT, in 가게id BIGINT, in 제목 varchar(50), in 내용 varchar(1000))
BEGIN
    declare 포스팅권한 ENUM('Y','N');
    select author_yn into 포스팅권한 from user where id = 사용자id;
    CASE  포스팅권한
      WHEN 'Y' THEN
        insert into posting(user_id,store_id,title,content)
        values(사용자id,가게id,제목,내용);
      ELSE
        select '권한이 없습니다.';
      END case;
END //
DELIMITER ;
-- 프로시저 호출
CALL 포스팅생성(2,2,'인생맛집','지금까지 이런 맛은 없었다. 이것은 갈비인가 통닭인가');
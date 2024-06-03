DELIMITER //

CREATE PROCEDURE AddReview(
    IN user_id BIGINT,
    IN store_id BIGINT,
    IN title VARCHAR(50),
    IN content VARCHAR(50),
    IN rating ENUM('1', '2', '3', '4', '5')
)
BEGIN
    DECLARE waiting_status ENUM('대기중', '완료', '취소');

    -- 사용자가 완료 상태인지 확인
    SELECT status INTO waiting_status
    FROM waiting
    WHERE user_id = user_id AND store_id = store_id AND status = '완료';

    -- 대기 상태가 완료인 경우 리뷰 추가
    IF waiting_status = '완료' THEN
        INSERT INTO review (store_id, user_id, title, content, rating, created_time)
        VALUES (store_id, user_id, title, content, rating, CURRENT_TIMESTAMP);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '사용자가 완료 상태가 아니거나 해당 레코드를 찾을 수 없습니다.';
    END IF;
END //

DELIMITER ;

INSERT INTO `group` (name, created_time) VALUES ('테스트 그룹', CURRENT_TIMESTAMP);

INSERT INTO waiting (store_id, user_id, group_id, status, created_time) VALUES (1, 1, 1, '완료', CURRENT_TIMESTAMP);

CALL AddReview(1, 1, '좋은 장소입니다!', '음식과 서비스가 정말 좋았어요.', '5');

select *
from review;
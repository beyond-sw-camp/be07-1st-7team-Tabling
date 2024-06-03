-- 공지사항 전체조회
DELIMITER //
create procedure 공지사항전체조회()
begin
    select a.announcement_Id as no, a.title as 제목, a.content as 내용 from announcement a;
END
//DELIMITER ;
call 공지사항전체조회();

-- 공지사항 번호로 조회
DELIMITER //
create procedure 공지사항번호조회(in n int)
begin
    select a.announcement_Id as no,a.title as 제목, a.content as 내용 from announcement a where a.announcement_Id = n;
END
//DELIMITER ;
CALL 공지사항번호조회(3);

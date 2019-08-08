SELECT bno, title, content, writer, regDate, viewCnt
FROM tb1_board
WHERE bno = #{bno};

UPDATE tb1_board
SET
	title = #{title}
	, content = #{content}
WHERE bno = #{bno};

DELETE FROM tb1_board
WHERE bno = #{bno};
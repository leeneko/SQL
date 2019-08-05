# 데이터 베이스 생성
create database k_board;
# 계정 생성
create user 'ad'@'localhost' identified by '1234';
# 데이터 베이스에 대한 권한 설정
grant all privileges on k_board.* to 'ad'@'localhost';
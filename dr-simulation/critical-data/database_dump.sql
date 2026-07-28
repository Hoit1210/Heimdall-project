-- [Heimdall Critical Database Backup]
CREATE TABLE users (id INT PRIMARY KEY, username VARCHAR(50), role VARCHAR(20));
INSERT INTO users VALUES (1, 'admin', 'SuperAdmin'), (2, 'sec_officer', 'DevSecOps');

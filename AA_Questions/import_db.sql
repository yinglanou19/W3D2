
PRAGMA foreign_keys = ON;

DROP TABLE if exists questions;
DROP TABLE if exists question_follows;
DROP TABLE if exists replies;
DROP TABLE if exists question_likes;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL

  -- FOREIGN KEY (playwright_id) REFERENCES playwrights(id)
);



CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL, 

  FOREIGN KEY (author_id) REFERENCES users(id)
);



CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL
);


CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  parent_id INTEGER,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL 
);


CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL
);



INSERT INTO
  users(fname , lname)
VALUES
  ('Matt', 'Jang'),
  ('Yinglan', 'Ou');

INSERT INTO
  questions(title, body, author_id)
VALUES
  ('When is lunch?', 'Blah blah blah!!!!',1),
  ('When is dinner?', 'bLAH BLAH BLAH!!!!',2); 

INSERT INTO
  question_follows(user_id,question_id)
VALUES
  (1,1),
  (2,2),
  (1,2);

INSERT INTO
  replies(parent_id, question_id, user_id,body)
VALUES
  (NULL,1,2,'Hell YEah!!!~~~'),
  (1,1,1,"yeeeeeah!"),
  (NULL,2,1,"cool");

INSERT INTO
  question_likes(question_id,user_id)
VALUES
  (1,1),
  (1,2),
  (2,1);


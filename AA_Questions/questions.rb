require 'sqlite3'
require 'singleton'

class QuestionDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end

end

class Question
  attr_accessor :id, :title, :body, :author_id

  def self.all
    data = QuestionDBConnection.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def create 
    raise "#{self} already in database" if self.id
    QuestionDBConnection.instance.execute(<<-SQL, self.title, self.body, self.author_id)
      INSERT INTO
        questions (title, body, author_id)
      VALUES
        (?, ?, ?)
    SQL
    self.id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update 
   raise "#{self} already in database" if self.id
    QuestionDBConnection.instance.execute(<<-SQL, self.title, self.body, self.author_id, self.id)
      UPDATE
        questions
      SET
        title = ?, body = ?, author_id = ?
      WHERE
        id = ?
    SQL
  end

end


class User
  
  def self.all
    data = QuestionDBConnection.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end
  attr_accessor :id, :fname, :lname

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def create
    raise "#{self} already in database" if self.id
    QuestionDBConnection.instance.execute(<<-SQL, self.fname, self.lname)
      INSERT INTO
        users (fname,lname)
      VALUES
        (?, ?)
    SQL
    self.id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} already in database" if self.id
      QuestionDBConnection.instance.execute(<<-SQL, self.fname, self.lname, self.id)
        UPDATE
          users
        SET
          fname = ?, lname = ?
        WHERE
          id = ?
      SQL
  end

end


class Reply

  def self.all
    data = QuestionDBConnection.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  attr_accessor :id, :parent_id, :question_id, :user_id, :body
  
  def initialize(options)
    @id = options['id']
    @parent_id = options['parent_id']
    @question_id = options['question_id']
    @user_id = options['user_id']
    @body = options['body']
  end

  def create
    raise "#{self} already in database" if self.id
    QuestionDBConnection.instance.execute(<<-SQL,  self.parent_id, self.question_id, self.user_id, self.body)
      INSERT INTO
        replies (parent_id, question_id, user_id, body)
      VALUES
        (?, ?, ?, ?)
    SQL
    self.id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} already in database" if self.id
      QuestionDBConnection.instance.execute(<<-SQL, self.parent_id, self.question_id, self.user_id, self.body, self.id)
        UPDATE
          replies
        SET
          parent_id =?, question_id=?, user_id=?, body=?
        WHERE
          id = ?
      SQL
  end

end
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
 #######################    QUESTION  ########################


 #######################              ########################
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

  def self.find_by_id(id)
    data = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT *
      FROM questions
      WHERE id = ?
    SQL
    return nil if data.length == 0
    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_author_id(author_id)
    data = QuestionDBConnection.instance.execute(<<-SQL, author_id)
        SELECT *
        FROM questions
        WHERE author_id = ?
    SQL
    return nil if data.length == 0
    data.map { |datum| Question.new(datum) }
  end

  def author 
    User.find_by_id(author_id)
  end

  def replies 
    Reply.find_by_question_id(id)
  end

  def followers
    QuestionFollow.followers_for_question_id(id)
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_question(n)
  end

  def likers
    QuestionLike.likers_for_question_id(id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(id)
  end



end

#######################    USER      ########################

#######################               ########################

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

  def self.find_by_id(id)
    data = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT *
      FROM users
      WHERE id = ?
    SQL
    data.map { |datum| User.new(datum) }
  end

  def self.find_by_name(fname, lname)
    data = QuestionDBConnection.instance.execute(<<-SQL, fname, lname)
      SELECT *
      FROM users
      WHERE fname = ? AND lname = ?
    SQL
    data.map { |datum| Question.new(datum) }
  end

  def authored_questions
     Question.find_by_author_id(id)
  end

  def authored_replies
    Reply.find_by_user_id(id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(id)
  end


end

#######################  REPLY ########################


####################### ########################


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
    raise "#{self} already in database" unless self.id
      QuestionDBConnection.instance.execute(<<-SQL, self.parent_id, self.question_id, self.user_id, self.body, self.id)
        UPDATE
          replies
        SET
          parent_id =?, question_id=?, user_id=?, body=?
        WHERE
          id = ?
      SQL
  end

  def self.find_by_id(id)
    data = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT *
      FROM replies
      WHERE id = ?
    SQL
    return nil if data.length == 0
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_user_id(user_id)
    data = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT *
      FROM replies
      WHERE user_id = ?
    SQL
    return nil if data.length == 0
    data.map { |datum| Reply.new(datum) }
  end


  def self.find_by_question_id(question_id)
    data = QuestionDBConnection.instance.execute(<<-SQL, question_id)
        SELECT *
        FROM replies
        WHERE question_id = ?
      SQL
      return nil if data.length == 0
      data.map { |datum| Reply.new(datum) }
  end

  def author 
    User.find_by_id(user_id)
  end

  def question 
    Question.find_by_id(question_id)
  end

  def parent_reply
    Reply.find_by_id(parent_id)
  end

  def child_replies
    data = QuestionDBConnection.instance.execute(<<-SQL, id)
        SELECT *
        FROM replies
        WHERE parent_id = ?
      SQL
      return nil if data.length == 0
      data.map { |datum| Reply.new(datum) }
  end
end

#######################    QUESTION FOLLOW  ########################


 #######################              ########################
class QuestionFollow
  attr_accessor :id, :title, :body, :author_id

  def self.all
    data = QuestionDBConnection.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionFollow.new(datum) }
  end

  def initialize(options)
    @user_id = options['user_id']
    @question_id = options['question_id']
    @id = options['id']
  end

  def create 
    raise "#{self} already in database" if self.id
    QuestionDBConnection.instance.execute(<<-SQL, self.user_id, self.question_id)
      INSERT INTO
        question_follows (user_id, question_id)
      VALUES
        (?, ?)
    SQL
    self.id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update 
    raise "#{self} already in database" unless self.id
    QuestionDBConnection.instance.execute(<<-SQL, self.user_id, self.question_id, self.id)
      UPDATE
        questions
      SET
        user_id = ?, question_id = ?
      WHERE
        id = ?
    SQL
  end

  def self.followers_for_question_id(question_id)
    data = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT *
      FROM question_follows
      JOIN users ON question_follows.user_id = users.id 
      WHERE question_id = ?

    SQL
    return nil if data.length == 0
    data.map { |datum| User.new(datum) }
  end

  def self.followed_questions_for_user_id(user_id)
    data = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT *
      FROM question_follows
      JOIN questions ON question_follows.question_id = questions.id 
      WHERE user_id = ?

    SQL
    return nil if data.length == 0
    data.map { |datum| Question.new(datum) }
  end

  def self.most_followed_question(n)
    data = QuestionDBConnection.instance.execute(<<-SQL, n)
      SELECT *
      FROM question_follows
      JOIN questions ON question_follows.question_id = questions.id 
      GROUP BY questions.id
      ORDER BY COUNT(*) DESC
      LIMIT ?
      SQL
      data.map { |datum| Question.new(datum) }
  end
end

#######################    QUESTION LIKE      ########################

#######################               ########################

class QuestionLike
  
  def self.all
    data = QuestionDBConnection.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| QuestionLike.new(datum) }
  end
  attr_accessor :question_id, :user_id

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end
def create 
    raise "#{self} already in database" if self.id
    QuestionDBConnection.instance.execute(<<-SQL, self.question_id, self.user_id)
      INSERT INTO
        question_likes (question_id, user_id)
      VALUES
        (?, ?)
    SQL
    self.id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update 
    raise "#{self} already in database" unless self.id
    QuestionDBConnection.instance.execute(<<-SQL, self.user_id, self.question_id, self.id)
      UPDATE
        question_likes
      SET
        user_id = ?, question_id = ?
      WHERE
        id = ?
    SQL
  end

  def self.likers_for_question_id(question_id)
    data = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT *
      FROM question_likes
      JOIN users ON question_likes.user_id = users.id 
      WHERE question_id = ?

    SQL
    return nil if data.length == 0
    data.map { |datum| User.new(datum) }
  end
  def self.num_likes_for_question_id(question_id)
    data = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT count(*) AS num
      FROM question_likes
      WHERE question_id = ?
    SQL
    data.first['num']
  end

  def self.liked_questions_for_user_id(user_id)
    data = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT *
      FROM question_likes
      JOIN questions ON question_likes.question_id = questions.id 
      WHERE user_id = ?

    SQL
    return nil if data.length == 0
    data.map { |datum| Question.new(datum) }
  
  end

  def self.most_liked_questions(n)
    data = QuestionDBConnection.instance.execute(<<-SQL, n)
      SELECT *
      FROM question_likes
      JOIN questions ON question_likes.question_id = questions.id 
      GROUP BY questions.id
      ORDER BY COUNT(*) DESC
      LIMIT ?
      SQL
      data.map { |datum| Question.new(datum) }
  end


end
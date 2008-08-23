require 'bp_test_case'
require 'name'

class NameTest < BPTestCase

  def test_puzzle_names(n, f, c)
    assert_equal f, n.puzzle_file_name
    assert_equal c, n.puzzle_class_name
  end

  def test_story_names(n, f, c)
    assert_equal f, n.story_file_name
    assert_equal c, n.story_class_name
  end


  def test_create_names_from_simple_puzzle_name
    n = Name.new("toto")
    test_puzzle_names(n, "toto_puzzle.rb", "TotoPuzzle")
    test_story_names(n,"toto_puzzle_story.rb", "TotoPuzzleStory")
  end

  def test_create_names_from_name_with_puzzle
    n = Name.new("toto_puzzle")
    test_puzzle_names(n, "toto_puzzle.rb", "TotoPuzzle")
    test_story_names(n,"toto_puzzle_story.rb", "TotoPuzzleStory")
  end

  def test_create_names_from_file_name_with_no_leading_folders
    n = Name.new("toto_puzzle.rb")
    test_puzzle_names(n, "toto_puzzle.rb", "TotoPuzzle")
    test_story_names(n,"toto_puzzle_story.rb", "TotoPuzzleStory")
  end

  def test_create_names_from_file_name_with_leading_folders_and_rb
    n = Name.new("foo/bar/toto_puzzle.rb")
    assert_equal "toto_puzzle", n.base_name
    test_puzzle_names(n, "foo/bar/toto_puzzle.rb", "TotoPuzzle")
    test_story_names(n,"foo/bar/toto_puzzle_story.rb", "TotoPuzzleStory")
  end

  def test_creates_names_from_file_name_with_leading_folders_but_no_rb
    n = Name.new("foo/bar/toto_puzzle")
    assert_equal "toto_puzzle", n.base_name
    test_puzzle_names(n, "foo/bar/toto_puzzle", "TotoPuzzle")
    test_story_names(n,"foo/bar/toto_puzzle_story", "TotoPuzzleStory")
  end

  def test_raise_exception_on_an_impossible_to_interpret_name
    begin
      n = Name.new("foo/bar/toto.rb")
      bad("A name should not end with .rb unless it ends with _plugins.rb")
    rescue NameError => e
      assert_equal "Cannot compute a puzzle base name for foo/bar/toto.rb", e.message
    end
  end

  def test_puzzle_class_name_can_be_overriden
    n = Name.new("toto_puzzle", :puzzle_class_name => "BlaBlaPuzzle")
    test_puzzle_names(n, "toto_puzzle.rb", "BlaBlaPuzzle")
    test_story_names(n,"toto_puzzle_story.rb", "BlaBlaPuzzleStory")
  end

end

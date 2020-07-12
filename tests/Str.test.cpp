#include <gmock/gmock.h>
#include <gtest/gtest.h>
#include <lil/Str.hpp>
#include <string>

using testing::ElementsAre;
using namespace lil;

//static_assert(4 == Str::literal("1234").size(), "constexpr string size broke!");

TEST(StrTest, CEndPositionCorrect)
{
  const std::string expected = "abcd";
  const Str<5>      actual   = "abcd";

  ASSERT_EQ(std::distance(expected.cend(), expected.cbegin()), std::distance(actual.cend(), actual.cbegin()));
}

TEST(StrTest, SizeIsCorrect)
{
  std::string expected;
  Str<5>      actual;

  ASSERT_EQ(expected.size(), actual.size());

  expected.push_back('a');
  expected.push_back('b');
  expected.push_back('c');
  expected.push_back('d');
  actual.push_back('a');
  actual.push_back('b');
  actual.push_back('c');
  actual.push_back('d');

  ASSERT_EQ(expected.size(), actual.size());
}

TEST(StrTest, ConstructFromStdString)
{
  std::string input = "input";
  Str<3>      output(input);
  ASSERT_STREQ(output.c_str(), "in");
}

TEST(StrTest, ConstructFromStringLiteral)
{
  Str<3> output("input");
  ASSERT_STREQ(output.c_str(), "in");
}

TEST(StrTest, ConstructFromShorterstring)
{
  Str<3> input("in");
  Str<5> output(input);
  ASSERT_STREQ(output.c_str(), "in");
}

TEST(StrTest, ConstructFromLongerstring)
{
  Str<6> input("input");
  Str<3> output(input);
  ASSERT_STREQ(output.c_str(), "in");
}

TEST(StrTest, ConstructFromSameSizestring)
{
  Str<3> input = "in";
  Str<3> output(input);
  ASSERT_STREQ(output.c_str(), "in");
}

TEST(StrTest, InsertIndividualCharacters)
{
  //! [Inserting fitting chars]
  // Given a string of 10 character capacity including null terminator.
  Str<10> actual = "58";
  ASSERT_EQ(2u, actual.size());

  // Insert the character '1', 1 time, at position 0. This inserts to the front. "58" becomes "158".
  actual.insert(0, 1, '1');
  ASSERT_STREQ("158", actual.c_str());
  ASSERT_EQ(3u, actual.size());

  // Insert the character '0', 3 times, at position 1. "158" becomes "100058".
  actual.insert(1, 3, '0');
  ASSERT_STREQ("100058", actual.c_str());
  ASSERT_EQ(6u, actual.size());

  // Insert the character '0', 2 times, at position 5. "100058" becomes "10005008".
  actual.insert(5, 2, '0');
  ASSERT_STREQ("10005008", actual.c_str());
  ASSERT_EQ(8u, actual.size());

  // Insert the character '0', 1 time, at position 8. This functionally appends. "10005008" becomes "100050080".
  actual.insert(8, 1, '0');
  ASSERT_STREQ("100050080", actual.c_str());
  ASSERT_EQ(9u, actual.size());

  // Inserting a character zero times does not modify the string.
  actual.insert(5, 0, 'X');
  ASSERT_STREQ("100050080", actual.c_str());
  ASSERT_EQ(9u, actual.size());
  //! [Inserting fitting chars]
}

TEST(StrTest, InsertIndividualCharactersBeyondBounds)
{
  //! [Inserting overflowing chars]
  // Given a string of 5 character capacity including null terminator.
  Str<5> actual = "234";

  // This insertion does not overflow. "234" becomes "1234".
  actual.insert(0, 1, '1');
  ASSERT_STREQ("1234", actual.c_str());

  // This insertion overflows. The rightmost characters that don't fit are truncated off, so "1234" becomes "0123".
  actual.insert(0, 1, '0');
  ASSERT_STREQ("0123", actual.c_str());

  // This insertion overflows. The rightmost characters that don't fit are truncated off, so "0234" becomes "0000".
  actual.insert(1, 3, '0');
  ASSERT_STREQ("0000", actual.c_str());

  // If we insert far beyond the capacity of the string, we can essentially wipe it.
  actual.insert(1, 10, '1');
  ASSERT_STREQ("0111", actual.c_str());

  // Inserting outside the extent of the string does not modify the string.
  actual.insert(10, 10, 'X');
  ASSERT_STREQ("0111", actual.c_str());
  //! [Inserting overflowing chars]
}

TEST(StrTest, InsertCString)
{
  Str<10> actual = "345";

  actual.insert(0, "12");
  ASSERT_STREQ("12345", actual.c_str());

  actual.insert(5, "67");
  ASSERT_STREQ("1234567", actual.c_str());

  actual.insert(4, "__");
  ASSERT_STREQ("1234__567", actual.c_str());

  actual.insert(4, "");
  ASSERT_STREQ("1234__567", actual.c_str());

  actual.insert(0, "___");
  ASSERT_STREQ("___1234__", actual.c_str());

  actual.insert(1, "99999999999999999999999");
  ASSERT_STREQ("_99999999", actual.c_str());

  actual.insert(99, "X");
  ASSERT_STREQ("_99999999", actual.c_str());
}

TEST(StrTest, InsertStringClass)
{
  Str<10> actual = "frog";

  const std::string prefix = "two ";
  actual.insert(0, prefix);
  ASSERT_STREQ("two frog", actual.c_str());

  //  const auto suffix = StrLiteral("s!");
  //  actual.insert(actual.size(), suffix);
  //  ASSERT_STREQ("two frogs", actual.c_str());
  //
  //  std::string dogs = " dogs";
  //  actual.insert(4, dogs);
  //  ASSERT_STREQ("two  dogs", actual.c_str());
}

TEST(StrTest, EraseByIndex)
{
  Str<11> actual = "0123456789";

  actual.erase(5, 0);
  ASSERT_STREQ("0123456789", actual.c_str());

  actual.erase(2, 2);
  ASSERT_STREQ("01456789", actual.c_str());

  actual.erase(0, 3);
  ASSERT_STREQ("56789", actual.c_str());

  actual.erase(3, 2);
  ASSERT_STREQ("567", actual.c_str());

  actual.erase(2, 1);
  ASSERT_STREQ("56", actual.c_str());

  actual.erase(0, actual.size());
  ASSERT_STREQ("", actual.c_str());

  actual = "0123456789";
  actual.erase(1, 99);
  ASSERT_STREQ("0", actual.c_str());
}

TEST(StrTest, EraseByIterator)
{
  Str<11> actual = "0123456789";

  actual.erase(actual.cbegin() + 5, actual.cbegin() + 5);
  ASSERT_STREQ("0123456789", actual.c_str());

  actual.erase(actual.cbegin() + 2, actual.cbegin() + 2 + 2);
  ASSERT_STREQ("01456789", actual.c_str());

  actual.erase(actual.cbegin(), actual.cbegin() + 3);
  ASSERT_STREQ("56789", actual.c_str());

  actual.erase(actual.cbegin() + 3, actual.cbegin() + 3 + 2);
  ASSERT_STREQ("567", actual.c_str());

  actual.erase(actual.cbegin() + 2, actual.cbegin() + 2 + 1);
  ASSERT_STREQ("56", actual.c_str());

  actual.erase(actual.cbegin() + 1);
  ASSERT_STREQ("5", actual.c_str());

  actual.erase(actual.cbegin());
  ASSERT_STREQ("", actual.c_str());
}

TEST(StrTest, Builder)
{
  //  const auto lhs          = StrLiteral("abc");
  //  const auto rhs          = StrLiteral("defg");
  //  const auto concatenated = (lhs % rhs);
  //  ASSERT_EQ(7u, concatenated.size());
  //  ASSERT_EQ(8u, concatenated.capacity());
}

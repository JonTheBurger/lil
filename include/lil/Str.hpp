#pragma once

// std
#include <stddef.h>
#include <stdint.h>
#include <string.h>

// local
#include <lil/Assert.hpp>
#include <lil/Err.hpp>
#include <lil/Interval.hpp>
#include <lil/detail/IArr.hpp>

namespace lil {

struct AtCompileTime {
};

template <uint8_t SIZE>
class Str : public IArr<Str<SIZE>, char> {
  char _data[SIZE];

public:
  Str()
  {
    clear();
  }

  Str(const char* str, size_t sz = MAX_CHARS)
  {
    auto input_size     = Str::len(str, sz);
    auto truncated_size = (input_size < MAX_CHARS ? input_size : MAX_CHARS);
    memcpy(_data, str, truncated_size);
    set_size_unsafe(truncated_size);
  }

  constexpr Str(const char (&literal)[SIZE], AtCompileTime)
      : _data{}
  {
    Str::cpy(_data, literal, SIZE);
  }

  template <typename TStr>
  Str(const TStr& other)
      : Str(other.c_str(), other.size())
  {
  }

  constexpr void set_size_unsafe(uint8_t sz) noexcept
  {
    //    LIL_ASSERT_DEBUG(sz <= MAX_CHARS, Err::OUT_OF_BOUNDS);
    _data[MAX_CHARS] = MAX_CHARS - sz;
    _data[size()]    = '\0';
  }

  constexpr void modify_size(int8_t diff) noexcept
  {
    set_size_unsafe(size() + diff);
  }

  constexpr void push_back(const char c)
  {
    //    LIL_ASSERT(!full(), Err::OUT_OF_BOUNDS);
    _data[size()] = c;
    modify_size(+1);
  }

  constexpr void pop_back() noexcept
  {
    _data[size() - 1] = '\0';
    modify_size(-1);
  }

  constexpr void clear() noexcept
  {
    set_size_unsafe(0);
  }

  /** Inserts @p count @p fill characters starting at @p index. Shifts all other characters right. If insertion overflows, the rightmost characters are truncated.
   * @snippet test_string.cpp Inserting fitting chars
   * @snippet test_string.cpp Inserting overflowing chars
   */
  constexpr Str& insert(size_t index, size_t count, char fill)
  {
    auto appended_size  = size() + count;
    auto truncated_size = (appended_size < MAX_CHARS ? appended_size : MAX_CHARS);

    for (size_t i = truncated_size; i >= (index + count); --i)
    {
      _data[i] = _data[i - count];
    }

    for (size_t i = 0; (i < count) && ((index + i) < MAX_CHARS); ++i)
    {
      _data[index + i] = fill;
    }

    set_size_unsafe(truncated_size);
    return *this;
  }

  constexpr Str& insert(size_t index, const char* str)
  {
    const auto count = Str::len(str, MAX_CHARS);
    return insert(index, str, count);
  }

  constexpr Str& insert(size_t index, const char* str, size_t count)
  {
    auto insertion_point = minimum(index, size());
    auto insertion_size  = minimum(count, MAX_CHARS - insertion_point);
    auto move_size       = size() - insertion_point;
    if (move_size + insertion_size > MAX_CHARS)
    {
      move_size -= insertion_size;
    }

    memmove(&_data[insertion_point + insertion_size], &_data[insertion_point], move_size);
    memcpy(&_data[insertion_point], str, insertion_size);

    auto appended_size = minimum(size() + insertion_size, MAX_CHARS);
    set_size_unsafe(appended_size);
    return *this;
  }

  template <typename TStr>
  constexpr Str& insert(size_t index, const TStr& str)
  {
    return insert(index, str.data(), str.size());
  }

  constexpr Str& append(size_t count, char fill) { return insert(size(), count, fill); }
  constexpr Str& append(const char* str) { return insert(size(), str); }
  constexpr Str& append(const char* str, size_t count) { return insert(size(), str, count); }
  template <typename TStr>
  constexpr Str& append(const TStr& str)
  {
    return insert(size(), str);
  }

  constexpr Str& erase(size_t index, size_t count)
  {
    auto erase_point = minimum(index, size());
    auto move_size   = size() - erase_point;
    auto erase_size  = minimum(count, size() - index);
    memmove(&_data[erase_point], &_data[erase_point + erase_size], size() - index);
    modify_size(-erase_size);

    return *this;
  }

  constexpr Str& erase(const char* position) { return erase(position - this->cbegin(), 1); }
  constexpr Str& erase(const char* first, const char* last) { return erase(first - this->cbegin(), last - first); }

  constexpr Str& operator+=(char chr) { return append(&chr, sizeof(chr)); }
  constexpr Str& operator+=(const char* str) { return append(str); }
  template <typename TString>
  constexpr Str& operator+=(const TString& str)
  {
    return append(str);
  }

  constexpr char*       data() noexcept { return &_data[0]; }
  constexpr const char* data() const noexcept { return &_data[0]; }
  constexpr const char* c_str() const noexcept { return &_data[0]; }
  constexpr bool        full() const noexcept { return size() == max_size(); }
  constexpr size_t      size() const noexcept { return max_size() - available(); }  ///< Number of characters in the string. This excludes final null-terminator.
  constexpr size_t      max_size() const noexcept { return MAX_CHARS; }
  constexpr size_t      capacity() const noexcept { return MAX_CHARS; }
  constexpr size_t      available() const noexcept { return _data[MAX_CHARS]; }

  static inline constexpr char* cpy(char* dst, const char* src, size_t n)
  {
    size_t i = 0;
    for (; ((i < n) && (src[i] != '\0')); ++i)
    {
      dst[i] = src[i];
    }
    for (; i < n; ++i)
    {
      dst[i] = '\0';
    }
    dst[n - 1] = '\0';
    return dst;
  }

  static inline constexpr size_t len(const char* str, size_t n)
  {
    size_t length = 0;
    for (; (length < n) && (str[length] != '\0'); ++length)
    {
    }
    return length;
  }

private:
  static_assert(SIZE >= 1, "Str must hold at least the null terminator");
  static constexpr size_t MAX_CHARS = SIZE - sizeof('\0');  ///< Maximum number of non-null terminator characters that can be stored. This is the index of the final character.
};

template <uint8_t SIZE>
constexpr size_t Str<SIZE>::MAX_CHARS;

template <uint8_t SIZE>
static constexpr Str<SIZE> str_literal(const char (&literal)[SIZE])
{
  return Str<SIZE>(literal, AtCompileTime{});
}

template <uint8_t LSIZE, uint8_t RSIZE>
constexpr auto operator%(const Str<LSIZE>& lhs, const Str<RSIZE>& rhs)
{
  Str<LSIZE + RSIZE - sizeof('\0')> concatenated = "";
  return concatenated.append(lhs)
    .append(rhs);
}

}  // namespace lil

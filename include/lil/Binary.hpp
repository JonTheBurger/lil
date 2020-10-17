#pragma once

#include <stddef.h>
#include <stdint.h>

namespace lil {

template <typename T>
struct BitCount {
  static constexpr size_t Value = sizeof(T) * 8;
};

template <typename T>
constexpr size_t Bit_Count_v = BitCount<T>::Value;

constexpr int clz(uint64_t value) noexcept
{
  return __builtin_clzll(value);
}

constexpr int clz(uint32_t value) noexcept
{
  return __builtin_clz(value);
}

constexpr int bitsToRepresent(uint64_t value) noexcept
{
  return Bit_Count_v<uint64_t> - clz(value);
}

constexpr int intBitsToFit(uint64_t value) noexcept
{
  if (value <= 8)
  {
    return 8;
  }
  if (value <= 16)
  {
    return 16;
  }
  if (value <= 32)
  {
    return 32;
  }
  if (value <= 64)
  {
    return 64;
  }
  return -1;
}

template <size_t Bits>
struct BitsToInt;

template <size_t Bits>
using BitsToInt_t = typename BitsToInt<Bits>::sint;

template <size_t Bits>
using BitsToUInt_t = typename BitsToInt<Bits>::uint;

template <>
struct BitsToInt<0> {
};

template <>
struct BitsToInt<8> {
  using sint = int8_t;
  using uint = uint8_t;
};

template <>
struct BitsToInt<16> {
  using sint = int16_t;
  using uint = uint16_t;
};

template <>
struct BitsToInt<32> {
  using sint = int32_t;
  using uint = uint32_t;
};

template <>
struct BitsToInt<64> {
  using sint = int64_t;
  using uint = uint64_t;
};

template <size_t Bits>
struct BitsToInt {
  using sint = typename BitsToInt<intBitsToFit(Bits)>::sint;
  using uint = typename BitsToInt<intBitsToFit(Bits)>::uint;
};

}  // namespace lil

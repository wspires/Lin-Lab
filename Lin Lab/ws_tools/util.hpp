//
//  util.hpp
//  Lin Lab
//
//  Created by Wade Spires on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef __UTIL_HPP
#define __UTIL_HPP

// c++ headers
#include <exception>
#include <sstream>
#include <string>
#include <vector>

// c headers
#include <cerrno>
#include <cmath>
#include <cstdarg>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <cctype>

// system headers
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>

namespace ws_tools
{
	/**
		Returns true for all strings (used as default parameter to dir_traverse().
		@param[in] s File name (not used)
	 */
	inline bool all_true( const std::string& s )
	{
		return( true );
	}

	typedef int prec_type;  //< Precision type for setting double's precision

	extern std::vector<std::string> dir_open(
			const std::string& directory_name,
			bool (*f)( const std::string& ) = all_true );

	extern std::vector<std::string> dir_traverse(
			const std::string& directory_name,
			bool (*f)( const std::string& ) = all_true );

	extern void check_dir( std::string&, bool = true );

	extern std::string sub_home( const std::string& );
	extern FILE* open_file( const std::string&, const std::string& );
	extern void close_file( FILE* );

	/*
		Get different portions of file name--get directory path, file name only,
		file name without extension, or file extension, respectively.
	 */
	extern std::string get_dir_name(  const std::string& );
	extern std::string get_file_name( const std::string& );
	extern std::string get_base_name( const std::string& );
	extern std::string get_ext_name(  const std::string& );

	// abbreviated names for the above
	extern std::string get_dir(  const std::string& );
	extern std::string get_file( const std::string& );
	extern std::string get_base( const std::string& );
	extern std::string get_ext(  const std::string& );

	extern double string_to_double( const std::string& );
	extern std::string int_to_string( const int );
	extern double double_prec( const double, prec_type );

	extern std::string& remove_comments( std::string&,
			const std::string& = "#" );
	extern std::vector<std::string> split_string( const std::string&,
			const std::string& = " \t\n\r" );

	extern std::string format_string( char*, ... );

	/**
		Determine if value is odd.
		@param[in] val Value
		@return odd Whether val is odd (true) or not (false)
	 */
	inline bool
	is_odd( unsigned val )
	{
		return( val & 01 );
	}

	/**
		Determine if value is even.
		@param[in] val Value
		@return even Whether val is even (true) or not (false)
	 */
	inline bool
	is_even( unsigned val )
	{
		return( !is_odd( val ) );
	}

	/**
		Determine if value is a power of 2.
		@param[in] val Value
		@return power_of_2 Whether val is power of 2 (true) or not (false)
	 */
	inline bool
	is_power_of_2( unsigned val )
	{
		/*
			A power of 2 in binary has a single 1 followed by all 0s, which
			implies subtracting 1 from it yields a 0 followed by all 1s. Hence,
			none of the bits in the two numbers should match.
			E.g., i = 1000 => i & (i - 1) = 1000 & 0111 = 0000
		 */
		return( val > 0 && (val & (val - 1)) == 0 );
	}

	/**
		Round given value to an unsigned integar.
		@param[in] v Value to round
	 */
	inline unsigned uround( double v )
	{
		// call math library's round and cast to unsigned
		return( static_cast<unsigned>( round( v ) ) );
	}

	/**
		Update running average (arithmetic) and variance of data.

		The function should be called with each new data item seen.  item_num
		should be 0 based, i.e., for the first item, 0 should be passed for
		item_num, 1 should be passed for the second item, etc.  The final
		variance should be calculated separately after the last call to this
		function and is given by (*var / (n - 1)) where n is the total number of
		data items.

		This is the one-dimensional version of the formula from "Pattern
		Classification" by Duda, Hart, and Stork in Chapter 3, problem 35, on
		page 150.  

		@param[in] new_val New value to update statistics with
		@param[in] item_num Number of items that have been seen up to this
			point (0 should be given for the first item, 1 for the second, etc.)
		@param[in,out] avg Running average
		@param[in,out] var Running variance (divide by the number of data items
			minus one after calling stat() on all data to obtain the variance)

		@pre The running average and variance must be initialized to 0 prior to
			the first call to stat(). 'avg' and 'var' must point to valid memory.
		@post The running variance must be divided by (n - 1) where n is the
			number of data items after the last call to stat().  
	 */
	inline void
	stat( double new_val, unsigned item_num, double* avg, double* var )
	{
		const double delta = new_val - *avg;
		*avg += delta / (item_num + 1);
		*var += delta * (new_val - *avg);
	}

	/**
		Convert string to uppercase.
		@param[in,out] str String to convert
		@retval str Converted string
	 */
	extern std::string& to_upper( std::string& );

	/**
		Convert string to lowercase.
		@param[in,out] str String to convert
		@retval str Converted string
	 */
	extern std::string& to_lower( std::string& );

	extern std::vector<std::string> merge_quoted_words(
			std::vector<std::string>& );

	/**
		Determine the number of digits in the given number.
		@param[in] num Number to find the digit count in
		@retval number_of_digits Number of digits in the given number
	 */
	extern int count_digits( unsigned );

} // namespace ws_tools

#endif // __UTIL_HPP 

//
//  Random_Number.hpp
//  Lin Lab
//
//  Created by Wade Spires on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef _RANDOM_NUMBER_HPP
#define _RANDOM_NUMBER_HPP

#define NDEBUG  // comment this line out to enable assert() debugging calls
#include <cassert>

// c++ headers
#include <algorithm>
#include <string>
#include <vector>

// c headers
#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <cstring>

// tools headers
#include "ws_tools.hpp"

namespace ws_tools
{

/**
	@brief Random_Number Base class for other random number generators.
 */
class Random_Number
{
	
public:

	/**
		Default constructor.
	 */
   Random_Number( )
	: _seed( static_cast<unsigned int>(std::time(0)) )
	{ }

	/**
		Destructor does nothing since no member variables are dynamically
		allocated.
	 */
   virtual ~Random_Number( )
	{ }

	/**
		Return the next random number.
		@retval number Next random number
	 */
	virtual double next( ) = 0;

	/**
		Return the next random number.
		@retval number Next random number
	 */
	virtual double operator()( ) = 0;

protected:

	/**
		Get the pointer to the seed being used for the generator.
		@retval seed_pointer Pointer to the seed
	 */
	inline unsigned* get_seed( )
	{
		return( &_seed );
	}

private:

	/// Seed for random number generator
	unsigned _seed;

};

/**
	@brief Uniform_Number
 */
class Uniform_Number : public Random_Number
{
	
public:


	/**
		Default constructor that seeds the number generator with the current time.
	 */
   Uniform_Number( double min = 0.0, double max = 1.0 )
	: Random_Number(), _min(min), _max(max)
	{
		if( _min >= _max )
		{
			//err_quit( "Uniform_Number: min (%lf) >= max (%lf)\n",
			//		_min, _max );
		}
	}

	/**
		Destructor does nothing since no member variables are dynamically
		allocated.
	 */
   virtual ~Uniform_Number( )
	{ }

	/**
		Return a uniformly distributed random number in the range [min, max).

		@retval number Next random number
	 */
	virtual inline double next( )
	{
		return( min()
				+ (max() - min()) * (rand_r( get_seed() ) / (RAND_MAX + 1.0)) );
	}

	/**
		Return a uniformly distributed random number in the range [min, max).
		@retval number Next random number
	 */
	virtual inline double operator()( )
	{
		return( next() );
	}

	/**
		Set new range for the distribution.
		@param[in] new_min New minimum value in the distribution's range
		@param[in] new_max New maximum value in the distribution's range
	 */
	virtual inline void range( double new_min, double new_max )
	{
		_min = new_min;
		_max = new_max;
		if( _min >= _max )
		{
			//err_quit( "Uniform_Number::range: min (%lf) >= max (%lf)\n",
			//		_min, _max );
		}
	}

	/**
		Return minimum value in the distribution's range.
		@retval min Minimum value in the distribution's range
	 */
	virtual inline double min( ) const
	{
		return( _min );
	}

	/**
		Set new minimum value in the distribution's range.
		@param[in] new_min New minimum value in the distribution's range
	 */
	virtual inline void min( double new_min )
	{
		// just change the range using the new min. and old max.
		range( new_min, max() );
	}

	/**
		Return maximum value in the distribution's range.
		@retval max Maximum value in the distribution's range
	 */
	virtual inline double max( ) const
	{
		return( _max );
	}

	/**
		Set new maximum value in the distribution's range.
		@param[in] new_max New maximum value in the distribution's range
	 */
	virtual inline void max( double new_max )
	{
		// just change the range using the old min. and new max.
		range( min(), new_max );
	}

	double _min;  //< Minimum value in the distribution's range
	double _max;  //< Maximum value in the distribution's range

};

} // namespace ws_tools

#endif // _RANDOM_NUMBER_HPP

//
//  util.cpp
//  Lin Lab
//
//  Created by Wade Spires on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "util.hpp"

#include "limits.h"

#include <set>
#include "unistd.h"

using std::set;
using std::string;
using std::vector;

namespace ws_tools
{

// define lower-level I/O stuff for Windows
#ifdef _WIN32
	#include <io.h>

	// Windows uses these numbers for access()
	#define W_OK 2
	#define R_OK 4

	// Windows prepends '_' to the function names
	#define lstat(p,s)  _stat((p),(s))
	#define access(p,m) _access((p),(m))
	#define mkdir(p,m)  _mkdir((p))

	// Windows does not have soft links or sockets (as far as I know or at least
	// as used here)
	#define S_ISLNK(m)     false
	#define S_ISSOCK(m)    false

	// Windows prepends '_' to the stat structure
	typedef struct  _stat  stat_struct;
	const string     directory_separator = "\\";
#else
	typedef struct  stat  stat_struct;
	const string     directory_separator = "/";
#endif // _WIN32

typedef std::set<string> Files_Seen;
bool have_seen( const string&, Files_Seen& );

/**
	Create list of all files found in the directory directory_name.
	Does not recursively check directories, see dir_traverse().

	@param[in] directory_name Name of directory to search for files
	@param[in] filter Predicate function invoked on all regular files--only those
		file names for which the predicate is true are added to the file list,
		which is useful for getting a list of files with the same file extension.
	@retval file_list List of all files found
 */
vector<string>
dir_open( const string& directory_name, bool (*filter)( const string& ) )
{
	vector<string> file_list;  // all file names to use
	Files_Seen files_seen;

	if( directory_name == "" )
	{
		return( file_list );
	}

	// remove slash from end of directory name and add home area if present
	string dir_name = sub_home( directory_name );
	string::size_type slash_pos = dir_name.find_last_of( directory_separator );
	if( slash_pos == dir_name.size() - 1 && slash_pos != 0 )
	{
		dir_name.erase( slash_pos );
	}

	// add initial directory to list of files to process
	vector<string> files_to_process;
	files_to_process.push_back( dir_name );

	// whether we have processed the first and only (for this function)
	// directory
	// Note: we use this flag since we put both the given input directory name
	// and all subsequent regular files in the directory inside the same vector
	bool processed_dir = false;

	// iterate through all files in the list
	for( unsigned i = 0; i != files_to_process.size(); i++ )
	{
		string file_name = files_to_process[i];

		// read file information into status buffer
		stat_struct stat_buf;
		if( lstat( file_name.c_str(), &stat_buf ) < 0 )
		{
			//err_warn( "Unable to access file '%s'\n", file_name.c_str() );
			continue;
		}

		// test for read permission
		else if( access( file_name.c_str(), R_OK ) < 0 )
		{
			//err_warn( "Unable to read file '%s'\n", file_name.c_str() );
			continue;
		}

		// if regular file
		if( S_ISREG( stat_buf.st_mode ) )
		{
			// apply filter to file name
			if( filter( file_name ) )
			{
				// add file to list of files
				file_list.push_back( file_name );
			}
		}

		// if directory (treat soft links as directories) and not already seen
		else if( (S_ISDIR( stat_buf.st_mode ) || S_ISLNK( stat_buf.st_mode )) )
		{
			if( processed_dir )
			{
				continue;
			}
			else
			{
				processed_dir = true;
			}

			// open directory file
			DIR* dfp;
			if( (dfp = opendir( file_name.c_str() )) == NULL )
			{
				// if link was soft link to regular file and not a directory,
				// then not an error--treat as regular file
				if( S_ISLNK( stat_buf.st_mode ) )
				{
					file_list.push_back( file_name );
					continue;
				}

				//err_quit( "Unable to open directory %s\n", dir_name.c_str() );
			}

			// read each directory entry
			dirent*  dep;
			while( (dep = readdir( dfp )) != NULL )
			{
				// get entry's name and skip current or parent directories
				string entry_name = dep->d_name;
				if( entry_name == "." || entry_name == ".." )
				{
					continue;
				}

				// create relative path to entry
				// string path_name = file_name + directory_separator + entry_name;
				string path_name = file_name;
				if( file_name != directory_separator )
				{
					path_name += directory_separator;
				}
				path_name += entry_name;

				// add path_name to list of files to process
				files_to_process.push_back( path_name );
			}

			if( closedir( dfp ) != 0 )
			{
				//err_quit( "Unable to close directory %s\n", dir_name.c_str() );
			}
		}
		// skip all other file types--links, block, etc.
		else if( S_ISLNK( stat_buf.st_mode ) )
      {
			// treated as directory (or regular file) above
			// err_warn( "Ignoring soft link: '%s'\n", file_name.c_str() );
      }
      else if( S_ISCHR( stat_buf.st_mode ) )
      {
			//err_warn( "Ignoring character special file: '%s'\n",
				//file_name.c_str() );
      }
      else if( S_ISBLK( stat_buf.st_mode ) )
      {
			//err_warn( "Ignoring block special file: '%s'\n", file_name.c_str() );
      }
      else if( S_ISFIFO( stat_buf.st_mode ) )
      {
			//err_warn( "Ignoring pipe file: '%s'\n", file_name.c_str() );
      }
      else if( S_ISSOCK( stat_buf.st_mode ) )
      {
			//err_warn( "Ignoring socket file: '%s'\n", file_name.c_str() );
      }
	}

	return( file_list );
}

/**
	Create list of all files found in the directory directory_name. Also,
	recursively check subdirectories.

	Directory traversal algorithm:
	Let L represent a list of file names
	Add the initial directory to L, so L holds 1 file name
	For each file in L
		If file is a regular file
			Add file to file list
		If file is a directory that has not already been seen
			Open directory
			For each directory entry
				If entry is not current or parent directory (i.e., '.' or '..')
					Create new path name by setting path = file_name/entry_name
					Add path to L

	@param[in] directory_name Name of directory to search for files
	@param[in] filter Predicate function invoked on all regular files--only those
		file names for which the predicate is true are added to the file list,
		which is useful for getting a list of files with the same file extension.
	@retval file_list List of all files found
 */
vector<string>
dir_traverse( const string& directory_name,
	bool (*filter)( const string& ) )
{
	vector<string> file_list;  // list of all files found
	Files_Seen files_seen;     // list of files we have already processed

	if( directory_name == "" )
	{
		return( file_list );
	}

	// remove slash from end of directory name and add home area if present
	string dir_name = sub_home( directory_name );
	string::size_type slash_pos = dir_name.find_last_of( directory_separator );
	if( slash_pos == dir_name.size() - 1 && slash_pos != 0 )
	{
		dir_name.erase( slash_pos );
	}

	// add initial directory to list of files to process
	vector<string> files_to_process;
	files_to_process.push_back( dir_name );

	// iterate through all files in the list
	for( unsigned i = 0; i != files_to_process.size(); i++ )
	{
		string file_name = files_to_process[i];

		// read file information into status buffer
		stat_struct stat_buf;
		if( lstat( file_name.c_str(), &stat_buf ) < 0 )
		{
			//err_warn( "Unable to access file '%s'\n", file_name.c_str() );
			continue;
		}

		// test for read permission
		else if( access( file_name.c_str(), R_OK ) < 0 )
		{
			//err_warn( "Unable to read file '%s'\n", file_name.c_str() );
			continue;
		}

		// if regular file
		if( S_ISREG( stat_buf.st_mode ) )
		{
			// apply filter to file name
			if( filter( file_name ) )
			{
				// add file to list of files
				file_list.push_back( file_name );
			}
		}

		// if directory (treat soft links as directories) and not already seen
		else if( (S_ISDIR( stat_buf.st_mode ) || S_ISLNK( stat_buf.st_mode ))
				&& !have_seen(file_name, files_seen) )
		{
			// open directory file
			DIR*  dfp;
			if( (dfp = opendir( file_name.c_str() )) == NULL )
			{
				// if link was soft link to regular file and not a directory,
				// then not an error--treat as regular file
				if( S_ISLNK( stat_buf.st_mode ) )
				{
					file_list.push_back( file_name );
					continue;
				}

				//err_quit( "Unable to open directory %s\n", dir_name.c_str() );
			}

			// read each directory entry
			dirent*  dep;
			while( (dep = readdir( dfp )) != NULL )
			{
				// get entry's name and skip current or parent directories
				string entry_name = dep->d_name;
				if( entry_name == "." || entry_name == ".." )
				{
					continue;
				}

				// create relative path to entry
				// string path_name = file_name + directory_separator + entry_name;
				string path_name = file_name;
				if( file_name != directory_separator )
				{
					path_name += directory_separator;
				}
				path_name += entry_name;

				// add path_name to list of files to process
				files_to_process.push_back( path_name );
			}

			if( closedir( dfp ) != 0 )
			{
				//err_quit( "Unable to close directory %s\n", dir_name.c_str() );
			}
		}
		// skip all other file types--links, block, etc.
		else if( S_ISLNK( stat_buf.st_mode ) )
      {
			// treated as directory (or regular file) above
			// err_warn( "Ignoring soft link: '%s'\n", file_name.c_str() );
      }
      else if( S_ISCHR( stat_buf.st_mode ) )
      {
			//err_warn( "Ignoring character special file: '%s'\n",
				//file_name.c_str() );
      }
      else if( S_ISBLK( stat_buf.st_mode ) )
      {
			//err_warn( "Ignoring block special file: '%s'\n", file_name.c_str() );
      }
      else if( S_ISFIFO( stat_buf.st_mode ) )
      {
			//err_warn( "Ignoring pipe file: '%s'\n", file_name.c_str() );
      }
      else if( S_ISSOCK( stat_buf.st_mode ) )
      {
			//err_warn( "Ignoring socket file: '%s'\n", file_name.c_str() );
      }
	}

	return( file_list );
}

/**
	Determine if file was seen already.

	@param[in] file_name File to check
	@param[in,out] files_seen List of files that have already been seen, which
		is added to if the given file has not been seen 
 */
bool have_seen( const string& file_name, Files_Seen& files_seen )
{
	// determine the size of the string returned by realpath()
#ifdef PATH_MAX
	static const int path_max = (int) PATH_MAX;
#else
	static const int path_max = (int) BUFSIZ;
#endif

	// expand file name path, including a sym. link, to the absolute real path
	// Note: there is a warning in the manpages about using realpath(), but no
	// alternative is given.
	char path_buf[ path_max ];
	realpath( file_name.c_str(), path_buf );

	// if it is already in the list, then we have seen the file 
	string path_str = path_buf;
	Files_Seen::iterator iter = files_seen.find( path_buf );
	if( iter == files_seen.end() )
	{
		// add file to list (and verify it was added)
		if( !files_seen.insert( path_str ).second )
		{
			//err_quit( "have_seen::Path was not inserted\n" );
		}
		
		return( false );
	}
	return( true );
}

/**
   Check output directory for proper access mode and name format.
   @param[in,out] dir Name of directory (after returning, dir will end with
		'/' if it did not already)
	@param[in] make_subdir Whether subdirectories should be created
		(e.g., check_dir("doc/reports", true) would create directory "doc" if
		it does not already exist; this is the default behavior)
 */
void
check_dir( string& dir, bool make_subdir )
{
	// if making subdirectories
	if( make_subdir && dir.size() > 0 )
	{
		// split input directory into separate directories
		const string dir_sep = directory_separator;
		vector<string> dirs = split_string( dir, dir_sep );

		// set initial directory to root or to current directory
		string current_dir = (dir[0] == dir_sep[0]) ? dir_sep : "";

		// iteratively create directories
		for( vector<string>::iterator iter = dirs.begin();
			iter != dirs.end();
			++iter )
		{
			// create name of next directory
			current_dir += *iter + directory_separator;

			// create next directory along dir path by calling itself with a
			// subdirectory guaranteed to exist
			check_dir( current_dir, false );
		}
	}

	// see if directory already exists:
	// read file information into status buffer
	stat_struct stat_buf;
	if( lstat( dir.c_str(), &stat_buf ) < 0 )
	{
		// if directory does not exist, create it with read/write/exec
		// permissions
		mode_t mode = S_IRUSR | S_IWUSR | S_IXUSR;
		if( mkdir( dir.c_str(), mode ) < 0 )
		{
			//err_quit( "Unable to make directory %s\n", dir.c_str() );
		}
	}
	// test for write permission
	if( access( dir.c_str(), R_OK ) < 0 )
	{
		//err_quit( "Unable to read directory '%s': No permission\n",
				//dir.c_str() );
	}
	if( access( dir.c_str(), W_OK ) < 0 )
	{
		//err_quit( "Unable to write directory '%s': No permission\n",
				//dir.c_str() );
	}

	// add slash to end of directory name if not present
	string::size_type slash_pos = dir.find_last_of( directory_separator );
	if( slash_pos != dir.size() - 1 )
	{
		dir += "/";
		// dir.erase( slash_pos );
	}
}

/**
	Substitute name of home area into file name.

	TODO improve Win32 support, e.g., %HOMEPATH% check

	@param[in] file_name Name of file
	@retval new_file_name New name of file
 */
string
sub_home( const string& file_name )
{
	// if a tilde is the first character of the file, substitute the home area
	// in for the tilde
	if( !file_name.empty() && file_name[0] == '~' )
	{
		// TODO 
		// e.g., ~some_user
		if( file_name.size() >= 2 && file_name[1] != directory_separator[0] )
		{
			//err_quit( "Need to substitute user's location\n" );
		}

#ifdef _WIN32
		string home = getenv( "HOMEPATH" );
#else
		string home = getenv( "HOME" );
#endif // _WIN32
		if( !home.empty() )
		{
			return( home + file_name.substr( 1, file_name.size() - 1 ) );
		}
	}

	// no substitution: return original file name
	return( file_name );
}

/**
	Open the given file.

	This is a wrapper for opening C-style file pointers using C++-style file
	names and performing a simple error check.  

	@param[in] file_name Name of file
	@param[in] mode Mode to open file in, such as "r" and "w" for read and write
	@retval fp File pointer
 */
FILE*
open_file( const string& file_name, const string& mode )
{
	// open file after substituting in the user's home area if necessary
	FILE* fp = NULL;
	if( (fp = fopen( sub_home(file_name).c_str(), mode.c_str() )) == NULL )
	{
		//err_quit( "Unable to open file '%s'\n", file_name.c_str() );
	}
	return( fp );
}

/**
	Close the given file.

	This is a wrapper for closing C-style file pointers that does simple error
	checking.  

	@param[in] fp File pointer to close that has been opened via a call to
		fopen() or ws_tools::open_file()
 */
void
close_file( FILE* fp )
{
	if( fp != 0 && fclose( fp ) != 0 )
	{
		//err_quit( "An error occurred while closing file\n" );
	}
	fp = 0;
}

/**
   Get the directory name from the given path.

   For example, '/home/wade/img.pgm' becomes '/home/wade'.

	@param[in] path Path information
 */
string
get_dir_name( const string& path )
{
	string copy = path;

   // remove slash from end of directory name if present, which leaves only the
	// first part of the name
   string::size_type slash_pos = copy.find_last_of( directory_separator );
	if( slash_pos == 0 )
	{
		// root directory, so don't erase
		copy = directory_separator;
	}
	else if( slash_pos != string::npos )
   {
      copy.erase( slash_pos, path.size() - slash_pos );
   }
	else // slash_pos == string::npos
	{
		copy = "";  // no directory information
	}

	return( copy );
}

/**
   Get the file name from the given path.
	
	All directory information is removed, e.g., '/home/wade/img.pgm' becomes
	'img.pgm'.

	@param[in] path Path information
 */
string
get_file_name( const string& path )
{
	string copy = path;

   // remove slash from end of directory name if present
   string::size_type slash_pos = copy.find_last_of( directory_separator );
   if( slash_pos != string::npos )
   {
      copy.erase( 0, slash_pos + 1 );
   }

	return( copy );
}

/**
   Get the base name from the given path.
	
	The file extension is removed, e.g., 'dir/img.pgm' becomes 'dir/img'.

	@param[in] path Path information
 */
string
get_base_name( const string& path )
{
	string copy = path;

   string::size_type dot_pos = copy.find_last_of( '.' );
   if( dot_pos != string::npos )
   {
      copy.erase( dot_pos, copy.size() - dot_pos );
   }

	return( copy );
}

/**
   Get the file extension from the given path.

	For example, '/home/wade/img.pgm' becomes 'pgm'.

	@param[in] path Path information
 */
string
get_ext_name( const string& path )
{
	// erase all characters up to and including the dot
	// if no dot exists, use the empty string
	string copy;
   string::size_type dot_pos = path.find_last_of( '.' );
   if( dot_pos != string::npos && dot_pos != (path.size() - 1) )
   {
		copy.assign( path, dot_pos + 1, path.size() - dot_pos - 1 );
	}

	return( copy );
}

string
get_dir( const string& path )
{
	return( get_dir_name(path) );
}

string
get_file( const string& path )
{
	return( get_file_name(path) );
}

string
get_base( const string& path )
{
	return( get_base_name(path) );
}

string
get_ext( const string& path )
{
	return( get_ext_name(path) );
}

/**
   Convert string to double.
   @param s String to convert
 */
double
string_to_double( const string& s )
{
   double value = 0;
   char*  endptr[ BUFSIZ ];  // location where strtod() puts errors encountered

   // convert string to double
   value = strtod( s.c_str( ), (char **) endptr );

   // verify string is a number--errors are in endptr
   string word( *endptr );
   if( !word.empty( ) && word != "-" )
   {
	fprintf( stderr, "%.20lf\n", value );
   }

   return( value );
}

/**
	Convert integer to string.
	@param i Integer to convert
 */
string
int_to_string( int i )
{
	// stringstream is probably safer but is not on some UNIX systems
    //char const * fmt = "%d";
	//return( format_string( fmt, i ) );

	char buf[ BUFSIZ ];
	sprintf( buf, "%d", i );
	return( string( buf ) );
	 
}

/**
	Remove inline comments from string s.
	@param[in,out] s String
	@param[in] comment_char String that begins a comment
	@retval s String with all characters following (and including) comment_char
		removed
 */
string&
remove_comments( string& s, const string& comment_char )
{
	// remove comments (if any)
	string::size_type comment_pos = s.find_first_of( comment_char );
	if( comment_pos != string::npos )
	{
		s.erase( comment_pos );
	}
	return( s );
}

/**
	Split string into a vector of words.

	TODO Store the found separators in a vector with the positions

	@param[in] string String to split
	@param[in] separators List of characters to use to separate string by
	@retval words List of words from string in the order that they appeared on
		the string
 */
vector<string>
split_string( const string& str, const string& separators )
{
	vector<string> words;

	string::size_type field_start = 0;
	string::size_type field_end   = 0;

	// get each word from string
	while(1)
	{
		// find start of next field using previous end of last field
		field_start = str.find_first_not_of( separators, field_end );

		// if no more fields are left, then stop
		if( field_start == string::npos )
		{
			break;
		}

		// find end of next field
		field_end = str.find_first_of( separators, field_start + 1 );

		// create individual field from substring in str
		string field = str.substr( field_start, field_end - field_start );

		words.push_back( field );
	}

	return( words );
}

/**
	Create a formatted string object from a C-style string.

   String can have conversion specifications (i.e., %d, %s, etc.) since
   format_string() takes a variable number of arguments.

	@param message -- message to format
 */
string
format_string( char* message, ... )
{
	// stringstream is probably safer but is not on some UNIX systems
	char buf[ BUFSIZ ];
   va_list v_args;

   va_start( v_args, message );
   int num_bytes = vsnprintf( buf, BUFSIZ, message, v_args );
	if( num_bytes >= BUFSIZ )
	{
	}
   va_end( v_args );

	return( string( buf ) );
}

/**
	Change precision of floating-point value.

	@param d Double value to change precision of
	@param prec Precision to change value to
 */
double
double_prec( const double d, prec_type prec )
{
	double value = 0;
	char buf[ BUFSIZ ];
	sprintf( buf, "%.*lf", prec, d );
	sscanf( buf, "%lf", &value );
	return( value );
}

/**
	Convert string to uppercase.
	@param[in,out] str String to convert
	@retval str Converted string
 */
string&
to_upper( string& str )
{
	for( unsigned i = 0; i != str.size(); ++i )
	{
		if( islower( str[i] ) )
		{
			str[i] = toupper( (int) str[i] );
		}
	}
	return( str );
}

/**
	Convert string to lowercase.
	@param[in,out] str String to convert
	@retval str Converted string
 */
string&
to_lower( string& str )
{
	for( unsigned i = 0; i != str.size(); ++i )
	{
		if( isupper( str[i] ) )
		{
			str[i] = tolower( (int) str[i] );
		}
	}
	return( str );
}

/**
	Combine individual words with quotes surrounding them into a single string
	without the quotes, e.g., if '/home/wade/some file' is stored as two
	white-space separated words, then combine them into a single string with the
	spaces added.  

	Can't handle double-quotes, multiple spaces, or tabs.

	@param[in,out] words List of words
	@retval new_words List of words with quoted words combined
 */
vector<string>
merge_quoted_words( vector<string>& words )
{
	vector<string> new_words;

	if( words.empty() )
	{
		return( new_words );
	}

	const char quote_char = '\'';
	unsigned idx_begin = 0;
	string::size_type quote_begin = 0;
	string::size_type quote_end = 0;
	while(1)
	{
		// search for first '

		// iterate through words until finding the first quote
		quote_begin = string::npos;
		for( ; idx_begin != words.size(); ++idx_begin )
		{
			quote_begin = words[idx_begin].find_first_of( quote_char );
			if( quote_begin != string::npos )
			{
				break;
			}
			else
			{
				// no quote in the words so just add it to the list as is
				new_words.push_back( words[idx_begin] );
			}
		}

		// stop if we found no quote
		if( quote_begin == string::npos )
		{
			break;
		}

		// search for matching '

		// try the word where we found the first quote, but start after it
		unsigned idx_end = idx_begin;
		quote_end = words[idx_end].find_first_of( quote_char, quote_begin + 1 );

		// search the other words if we did not find it in the first
		if( quote_end == string::npos )
		{
			for( idx_end = idx_begin + 1;
					idx_end != words.size();
					++idx_end )
			{
				quote_end = words[idx_end].find_first_of( quote_char );
				if( quote_end != string::npos )
				{
					break;
				}
			}
		}

		// if we have no end quote to match the beginning quote
		if( quote_end == string::npos )
		{
			// remove quote; copy all remaining words; finish
			words[idx_begin].erase( quote_begin, 1 );
			for( unsigned i = idx_begin; i != words.size(); ++i )
			{
				new_words.push_back( words[i] );
			}
			//err_warn( "Missing matching quote: Erasing first quote\n" );
			break;
		}

		// merge words

		// if quotes are located in the same word
		string new_word;
		if( idx_begin == idx_end )
		{
			// get substring between quotes
			new_word = words[idx_begin].substr(
					quote_begin + 1, quote_end - quote_begin - 1 );
		}
		else // quotes are located in different words
		{
			// add last part of the first word
			new_word = words[idx_begin].substr(
					quote_begin + 1, words[idx_begin].size() - quote_begin - 1 );

			// add complete words with spaces in-between
			for( unsigned i = idx_begin + 1; i != idx_end; ++i )
			{
				new_word += " " + words[i];
			}

			// add first part of the last word
			new_word += " " + words[idx_end].substr( 0, quote_end );
		}

		// add any part that comes before the quote
		string prefix_word = words[idx_begin].substr( 0, quote_begin );
		if( prefix_word != "" )
		{
			new_words.push_back( prefix_word );
		}

		// add the new word to list if non-empty
		if( new_word != "" )
		{
			new_words.push_back( new_word );
		}

		// copy remainder of word into vector, so we can scan it next 
		words[idx_end] = words[idx_end].substr(
				quote_end + 1, words[idx_end].size() - quote_end - 1 );

		// start searching again after the current end position
		idx_begin = idx_end;
		if( words[idx_end] == "" )
		{
			++idx_begin;
		}
	}
	return( new_words );
}

/**
	Determine the number of digits in the given number.
	@param[in] num Number to find the digit count in
	@retval number_of_digits Number of digits in the given number
 */
int
count_digits( unsigned num )
{
	// iterate i through the numbers 9, 99, 999, etc. until i is larger than
	// the given number
	int number_of_digits = 1;
	for( int i = 9; i < static_cast<int>( num ); i = (i * 10 + 9) )
	{
		++number_of_digits;
	}
	return( number_of_digits );
}

} // namespace ws_tools

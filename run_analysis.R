##########################################################################################
## run_analysis
##########################################################################################
run_analysis <- function( dir = 'UCI HAR Dataset' )
{
	library( dplyr )

	## create combined test & training data.frame
	data <- har.combine_data( dir )

	## filter out unwanted columns
	data <- har.select_columns( data )

	## load activity labels 
	labels <- har.load_activity_labels( dir )

	## replace activity identifier with a descriptive string
	data <- merge(
		x = data
		,y = labels
		,by.x = 'aid'
		,by.y = 'aid'
	)

	## remove the activity identifier
	data$aid <- NULL

	## group by the activity and subject
	data <- group_by( data, activity, subject )	

	## summarize with the average of each column
	tidy <- summarize_each( data, funs( mean ))

	return( tidy )
}



##########################################################################################
## har.assert
##		-- stop if expression is false with msg formed by combining remaining args
##########################################################################################
har.assert <- function( expr, ... )
{
	if( !expr )
	{
		stop( paste( 'ASSERT:', ..., collapse='' ))
	}
}



##########################################################################################
## har.load_features  
## 		-- read HAR feature names into data.frame 
##########################################################################################
har.load_features <- function( path )
{
	## check file exists
	har.assert( file.exists( path ), 'file not found:', path );

	## load file data
	df <- read.csv( 
		file = path							## path to file
		,header = FALSE						## file contains no header row
		,sep = ' '							## space separator character
		,row.names = 1						## use first column for row names
		,col.names = c( 'row', 'names' )	## name the columns in the file
	)

	## clean up column names
	df$names <- tolower( df$names )						## all lowercase
	df$names <- gsub( '[[:punct:]]', '', df$names )		## remove punctuation

	## return Nx1 data.frame
	return( df )
}



##########################################################################################
## har.load_vector
##		-- return a vector from a file containing a single variable
##########################################################################################
har.load_vector <- function( path, nrows )
{
	## check file exists
	har.assert( file.exists( path ), 'file not found:', path );

	## load file data
	df <- read.csv( 
		file = path					## path to file
		,header = FALSE				## file contains no header row
		,col.names = c( 'var' )		## name the column 
		,nrows = nrows				## how many rows to read
	)

	## return the vector variable
	return( df$var )
}



##########################################################################################
## har.load_data
## 		-- read either the X_train.txt or X_test.txt data file
##########################################################################################
har.load_data <- function( path, features, nrows )
{
	## check file exists
	har.assert( file.exists( path ), 'file not found:', path );

	## build vector of fixed column widths, all columns look like: ' -2.5717778e-001'
	widths <- rep( 16, nrow( features ))

	## load HAR data table
	df <- read.fwf( 
		file = path							## path to file
		,width = widths						## fixed column widths
		,col.names = features$names			## name the columns in the file
		,nrows = nrows						## how many rows to read
	)
}



##########################################################################################
# har.combine_data
#		-- read test and training data into one data.frame
##########################################################################################
har.combine_data <- function( folder, nrows = -1 )
{
	## validate HAR directory
	har.assert( dir.exists( folder ), 'directory not found:', folder )

	## load feature names
	path <- file.path( folder, 'features.txt' )
	features <- har.load_features( path )

	##
	## test data
	##

	## load test data.frame
	path <- file.path( folder, 'test', 'X_test.txt' )
	test <- har.load_data( path, features, nrows )

	## add activity variable to the data.frame
	path <- file.path( folder, 'test', 'y_test.txt' )
	test$aid <- har.load_vector( path, nrows )

	## add subject variable to the data.frame
	path <- file.path( folder, 'test', 'subject_test.txt' )
	test$subject <- har.load_vector( path, nrows )

	##
	## training data
	##

	## load training data.frame
	path <- file.path( folder, 'train', 'X_train.txt' )
	train <- har.load_data( path, features, nrows )

	## add activity variable to the data.frame
	path <- file.path( folder, 'train', 'y_train.txt' )
	train$aid <- har.load_vector( path, nrows )

	## add subject variable to the data.frame
	path <- file.path( folder, 'train', 'subject_train.txt' )
	train$subject <- har.load_vector( path, nrows )

	## row bind the two datasets
	data <- rbind( test, train )

	return( data )
}



##########################################################################################
## har.select_columns 
##		-- filter out unrequested columns from the data.frame
##########################################################################################
har.select_columns <- function( data )
{
	##
	## keep only 'mean' and 'std' columns
	##

	keep <- c(
		'aid'
		,'subject'
		,'mean'
		,'std'
	)

	## build regex pattern, looks like: 'a|b|c|d'
	pattern <- paste( keep, sep='', collapse='|' )

	## choose desired column indices
	idx <- grep( pattern, names( data ))

	## subset the data.frame
	return( data[ idx ])
}



##########################################################################################
## har.load_activity_labels 
##		-- load the activity label data.frame
##########################################################################################
har.load_activity_labels <- function( folder )
{
	## validate path
	path <- file.path( folder, 'activity_labels.txt' )
	har.assert( file.exists( path ), 'file not found:', path )

	## load the activity labels data.frame
	labels <- read.csv( 
		file = path							## path to file
		,header = FALSE						## file contains no header row
		,sep = ' '							## space separator character
		,col.names = c( 'aid', 'activity' )	## name the columns in the file
	)

	return( labels )
}

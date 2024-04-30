#!/bin/sh

set -e

WORKING_DIRECTORY="$(pwd)"
SOURCES_FOLDER="$1"
[[ "$2" == public-only ]] && PUBLIC_ONLY=1 || PUBLIC_ONLY=0
PRIVATE_HEADERS=()
PUBLIC_HEADERS=()
ALL_HEADERS=()
FILES=()


# Function allow retrieve relative path to header by it's filename.
path_for_file() {
	local relative_path=""
	for file in "${FILES[@]}"; do
		filename="${file%%:*}"
		path="${file##*:}"

		if [[ "$filename" == "$1" ]]; then
			relative_path="$path"
			break
		fi
	done

	echo "$relative_path"
}

store_public_header() {
	local headerAlreadyAdded=0
	for header in "${PUBLIC_HEADERS[@]}"; do
		if [[ "$header" == "$1" ]]; then
			headerAlreadyAdded=1
			break
		fi
	done

	if [[ $headerAlreadyAdded == 0 ]]; then
		PUBLIC_HEADERS+=("$1")
 	fi
}


# Function allow to retrieve list of headers which has been imported in file 
# and add them to public list of headers
gather_imported_headers_in_file() {
	regex="import \"(.*)\""
	while IFS='' read -r line; do
		[[ -z "$line" || ! "$line" =~ $regex ]] && continue
		imported_header_path="$(path_for_file "${BASH_REMATCH[1]}")"

		# Skip file which doesn't exists.
		if [[ -z "$imported_header_path" ]]; then 
			echo "WARNING: Imported file doesn't exists: ${BASH_REMATCH[1]}"
			continue
		fi
		
		store_public_header "$imported_header_path"
		gather_imported_headers_in_file "$SOURCES_FOLDER/$imported_header_path"
	done < "$1"
}


if [[ $PUBLIC_ONLY == 1 ]]; then
	regex=".*Private.h"
	# Retrieve list of potentially public headers.
	while IFS='' read -r HEADER_PATH; do
		RELATIVE_PATH="${HEADER_PATH#"$WORKING_DIRECTORY/$SOURCES_FOLDER/"}"
		FILENAME="$(echo "$RELATIVE_PATH" | rev | cut -d/ -f1 | rev)"
		FILES+=( "$FILENAME:$RELATIVE_PATH" )
		ALL_HEADERS+=("$RELATIVE_PATH")
		[[ "$RELATIVE_PATH" =~ $regex ]] && PRIVATE_HEADERS+=("$RELATIVE_PATH")
	done <<< "$(find "$WORKING_DIRECTORY/$SOURCES_FOLDER" -type f ! \( -name "*.m" -o -name ".DS_Store" -o -name "*Private.h" \))"

	# Scan for public headers
	gather_imported_headers_in_file "$SOURCES_FOLDER/PubNub.h"
else
	regex=".*Private.h"
	# Retrieve list of all headers.
	while IFS='' read -r HEADER_PATH; do
		RELATIVE_PATH="${HEADER_PATH#"$WORKING_DIRECTORY/$SOURCES_FOLDER/"}"
		FILENAME="$(echo "$RELATIVE_PATH" | rev | cut -d/ -f1 | rev)"
		FILES+=( "$FILENAME:$RELATIVE_PATH" )
		ALL_HEADERS+=("$RELATIVE_PATH")
		[[ "$RELATIVE_PATH" =~ $regex ]] && PRIVATE_HEADERS+=("$RELATIVE_PATH")
	done <<< "$(find "$WORKING_DIRECTORY/$SOURCES_FOLDER" -type f ! \( -name "*.m" -o -name ".DS_Store" \))"
fi


# Create required folders structure.
! [[ -d "$WORKING_DIRECTORY/Sources" ]] && mkdir -p "$WORKING_DIRECTORY/Sources"
! [[ -d "$1/include" ]] && mkdir -p "$1/include/PubNub"


# Create symbolic link to Objective-C SDK source files.
pushd "$WORKING_DIRECTORY/Sources"
! [[ -e PubNub ]] && ln -s ../PubNub
popd


# Create symbolic links for public headers
cd "$1/include/PubNub"

if [[ $PUBLIC_ONLY == 1 ]]; then
	for HEADER_PATH in "${PUBLIC_HEADERS[@]}"; do
		FILENAME="$(echo "$HEADER_PATH" | rev | cut -d/ -f1 | rev)"
		! [[ -e "$FILENAME" ]] && ln -s "../../$HEADER_PATH"
	done
else
	for HEADER_PATH in "${ALL_HEADERS[@]}"; do
		FILENAME="$(echo "$HEADER_PATH" | rev | cut -d/ -f1 | rev)"
		! [[ -e "$FILENAME" ]] && ln -s "../../$HEADER_PATH" "$FILENAME"
	done
fi

[[ -e "PubNub.h" ]] && rm "PubNub.h"

cd "../"

if [[ $PUBLIC_ONLY == 1 ]]; then
	for HEADER_PATH in "${PUBLIC_HEADERS[@]}"; do
		FILENAME="$(echo "$HEADER_PATH" | rev | cut -d/ -f1 | rev)"
		! [[ -e "$FILENAME" ]] && ln -s "../$HEADER_PATH"
	done
else
	for HEADER_PATH in "${ALL_HEADERS[@]}"; do
		FILENAME="$(echo "$HEADER_PATH" | rev | cut -d/ -f1 | rev)"
		! [[ -e "$FILENAME" ]] && ln -s "../$HEADER_PATH" "$FILENAME"
	done
fi

[[ -e "PubNub.h" ]] && rm "PubNub.h"
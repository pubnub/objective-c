import os
import argparse
import fnmatch
import plistlib
import urlparse
import urllib

test_fixture_directory = '/Users/jordan/Coding/objective-c/Tests/iOS Tests/Fixtures/'
test_plist = '/Users/jordan/Coding/objective-c/Tests/iOS Tests/Fixtures/PNUnsubscribeTests.bundle/testUnsubscribeWithPresence.plist'

class FixtureFinder(object):
	"""docstring for FixtureFinder"""
	def __init__(self, fixtures_path):
		super(FixtureFinder, self).__init__()
		self.fixtures_path = fixtures_path
	def get_all_bundles(self):
		bundles = []
		# first find all .bundle directories
		for directory in os.listdir(self.fixtures_path):
			if fnmatch.fnmatch(directory, '*.bundle'):
				plist_array = []
				# only include .bundles containing at least one .plist
				for plist in os.listdir(os.path.join(self.fixtures_path, directory)):
					if fnmatch.fnmatch(plist, '*.plist'):
						bundles.append(os.path.join(self.fixtures_path, directory))
						break
		return bundles
	def get_plists(self, bundle):
		plists_list = []
		for plist in os.listdir(bundle):
			if fnmatch.fnmatch(plist, '*.plist'):
				plists_list.append(os.path.join(bundle, plist))
		return plists_list

		

class FixtureUpdater(object):
	"""docstring for FixtureUpdater"""
	def __init__(self, plist):
		super(FixtureUpdater, self).__init__()
		self.plist_path = plist
	def get_plist_contents(self):
		recordings = plistlib.readPlist(self.plist_path)
		return recordings

class Recording(object):
	"""docstring for Recording"""
	def __init__(self, plist_item):
		super(Recording, self).__init__()
		self.plist_item = plist_item
	def get_requests(self):
		if 'request' in self.plist_item:
			return self.plist_item['request']
		return None
	def replace_sdk_version_in_URL(self, URLString, sdk_version):
		url_components = urlparse.urlparse(URLString)
		query_items = urlparse.parse_qs(url_components.query, True, True)
		final_query_string = None
		if 'pnsdk' in query_items:
			query_items['pnsdk'] = sdk_version
			final_query_string = urllib.urlencode(query_items, True)
		URLString = urlparse.urlunparse(urlparse.ParseResult(url_components.scheme, url_components.netloc, url_components.path, url_components.params, final_query_string, url_components.fragment))
		return URLString
	def update_specific_request(self, request, sdk_version):
		self.replace_sdk_version_in_URL(request['URL'], sdk_version)
		return request
	def updated_requests(self, requests, sdk_version):
		updated_requests = {}
		# pnsdk=PubNub-ObjC-iOS%2F4.0
		if 'currentRequest' in requests:
			updated_request = self.update_specific_request(requests['currentRequest'], sdk_version)
			# print updatedRequest
			updated_requests['currentRequest'] = updated_request
		if 'originalRequest' in requests:
			updated_request = self.update_specific_request(requests['originalRequest'], sdk_version)
			# print updatedRequest
			updated_requests['originalRequest'] = updated_request
		return updated_requests
	def replace_requests(self, sdk_version):
		original_requests = self.get_requests()
		updated_requests = self.updated_requests(original_requests, sdk_version)
		self.plist_item['request'] = updated_requests

def build_parser():
	parser = argparse.ArgumentParser(description='Update fixtures for new SDK versions')
	parser.add_argument('-f', '--fixtures', action='store', type=str, help='Supply path to directory containing all .bundle fixtures', required=True)
	parser.add_argument('-sdk', '--updatesdk', action='store', type=str, help='Supply the new version number to replace the old one')
	return parser
def get_args():
	parser = build_parser()
	return parser.parse_args()
		

def main():
	args = get_args()
	fixture_finder = FixtureFinder(args.fixtures)
	bundles = fixture_finder.get_all_bundles()
	for bundle in bundles:
		for plist in fixture_finder.get_plists(bundle):
			updater = FixtureUpdater(plist)
			recordings = updater.get_plist_contents()
			for plist_item in recordings:
				recording = Recording(plist_item)
				recording.replace_requests(args.updatesdk)





if __name__ == '__main__':
	main()
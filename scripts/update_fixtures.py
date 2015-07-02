import os
import argparse
import fnmatch
import plistlib

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
		

def main():
	fixture_finder = FixtureFinder(test_fixture_directory)
	bundles = fixture_finder.get_all_bundles()
	for bundle in bundles:
		for plist in fixture_finder.get_plists(bundle):
			updater = FixtureUpdater(plist)
			recordings = updater.get_plist_contents()
			for plist_item in recordings:
				recording = Recording(plist_item)
				print recording.get_requests()


if __name__ == '__main__':
	main()
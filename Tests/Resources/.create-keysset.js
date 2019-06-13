const glob = require("glob");
const path = require('path');
const fs = require('fs');


const keys = {
  TESTS_PAM_SUBSCRIBE_KEY: 'subscribe (PAM)',
  TESTS_PAM_PUBLISH_KEY: 'publish (PAM)',
  TESTS_SUBSCRIBE_KEY: 'subscribe',
  TESTS_PUBLISH_KEY: 'publish',
};
let allKeysSet = true;

Object.keys(keys).forEach(function (env) {
  if (allKeysSet && !process.env[env]) {
    console.error(`Environment variable for ${keys[env]} key is missing!`);
    allKeysSet = false;
  }
});

if (!allKeysSet) {
  console.error('Abort! Environment variables not set.');
  process.exit(1);
}

const replacementMap = {
  'psub-c-00000000-0000-0000-0000-000000000000': process.env.TESTS_PAM_SUBSCRIBE_KEY,
  'ppub-c-00000000-0000-0000-0000-000000000000': process.env.TESTS_PAM_PUBLISH_KEY,
  'rsub-c-00000000-0000-0000-0000-000000000000': process.env.TESTS_SUBSCRIBE_KEY,
  'rpub-c-00000000-0000-0000-0000-000000000000': process.env.TESTS_PUBLISH_KEY,
};

/** @type String[] */
const files = glob.sync("../../Tests/iOS Tests/Fixtures/**/*.plist");
files.forEach(function (file) {
  let content = fs.readFileSync(file, 'utf-8').toString();

  Object.keys(replacementMap).forEach(function (key) {
    content = content.split(key).join(replacementMap[key]);
  });

  fs.writeFileSync(file, content);
});

const content = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>regular</key>
	<dict>
		<key>subscribe</key>
		<string>${process.env.TESTS_SUBSCRIBE_KEY}</string>
		<key>publish</key>
		<string>${process.env.TESTS_PUBLISH_KEY}</string>
	</dict>
	<key>pam</key>
	<dict>
		<key>subscribe</key>
		<string>${process.env.TESTS_PAM_SUBSCRIBE_KEY}</string>
		<key>publish</key>
		<string>${process.env.TESTS_PAM_PUBLISH_KEY}</string>
	</dict>
</dict>
</plist>`;
fs.writeFileSync(path.join(process.cwd(), 'keysset.plist'), content);

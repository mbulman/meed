npm install express facebook-js ntwitter sqlite3 winston

coffee -c *.coffee

# Install ender + modules for ui
npm install -g ender
mkdir build
cd build
ender build domready reqwest winston

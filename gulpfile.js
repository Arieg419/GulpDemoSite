var gulp = require('gulp');
var shell = require('gulp-shell');
var uglify = require('gulp-uglify');
var livereload = require('gulp-livereload');
var concat = require('gulp-concat');
var minifyCss = require('gulp-minify-css');
var autoprefixer = require('gulp-autoprefixer');
var plumber = require('gulp-plumber');
var sourcemaps = require('gulp-sourcemaps');
var sass = require('gulp-sass');
var babel = require('gulp-babel');
// Could not dl zip module, b/c of firewall
//var zip = require('gulp-zip');
var del = require('del');

// File paths
var DIST_PATH = 'public/dist';
var SCRIPTS_PATH = 'public/scripts/main.js';
var OLDMAIN_PATH = '!public/scripts/oldmain.js';
var MARKUP_PATH = 'public/**/*.html';
var CSS_PATH = 'public/css/**/*.css';
var SCSS_PATH = 'public/scss/**/*.scss';
var BROWSERDATA_PATH = 'public/browserData/**/*.txt';

// David Strouk - Bash Code Diff + Update oldmain.js
gulp.task('shorthand', shell.task([
  'echo *********** Running Code Diff ************* ',
  './codeDiff.sh ./public/scripts/oldmain.js ./public/scripts/main.js'
]));

// Watch for changes in Browser Data
gulp.task('browserDataChange', shell.task([
  'echo *********** Running Browser Data ************* ',
  './browserAlert.sh'
  // Delete self and return.
]));

// styles for scss

gulp.task('styles', function() {
	console.log('starting scss styles task');
	return gulp.src(['public/scss/styles.scss'])
		.pipe(plumber(function(err){
			console.log("Styles task error");
			console.log(err);
			this.emit('end'); // stop running follwoing pipes, keep gulp up
		}))
		.pipe(sourcemaps.init())
		.pipe(autoprefixer())
		.pipe(sass({
			outputStyle: 'compressed'
		}))
		.pipe(sourcemaps.write())
		.pipe(gulp.dest(DIST_PATH))
		.pipe(livereload());
});


// scripts

gulp.task('scripts', function() {
	console.log('starting scripts task$');

	return gulp.src( [SCRIPTS_PATH ])
		.pipe(plumber(function(err) {
			console.log("Javascript error");
			console.log(err);
			this.emit('end');
		}))
		.pipe(sourcemaps.init())
		.pipe(babel({
			presets: ['es2015']
		}))
		.pipe(uglify())
		.pipe(concat('scripts.js'))
		.pipe(sourcemaps.write())
		.pipe(gulp.dest(DIST_PATH))
		.pipe(livereload());
});

// markups

gulp.task('markups', function() {
	console.log("I see html change");
	return gulp.src(MARKUP_PATH)
		.pipe(livereload());
});

gulp.task('clean', function() {
	return del.sync([
		DIST_PATH
	]);
});

gulp.task('default', [ 'markups', 'styles', 'scripts' ] , function() {
	console.log('starting default task');
});

gulp.task('watch', ['default'] , function() {
	console.log('starting watch task');
	// run code in server.js, and then run server.js
	require('./server.js')

	// livereload server is started, real server running on local machine.
	livereload.listen();

	// if scripts in SCRIPTS_PATH change, run 'scripts' task.
	gulp.watch(SCRIPTS_PATH, ['scripts', 'shorthand']);
  gulp.watch(BROWSERDATA_PATH, ['browserDataChange']);
	gulp.watch(SCSS_PATH, ['styles', 'shorthand']);
	gulp.watch(MARKUP_PATH, ['markups', 'shorthand']);
});

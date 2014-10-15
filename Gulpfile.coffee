gulp = require("gulp")
gutil = require("gulp-util")
concat = require("gulp-concat")
sass = require("gulp-sass")
minifyCss = require("gulp-minify-css")
rename = require("gulp-rename")
coffee = require("gulp-coffee")
sourcemaps = require("gulp-sourcemaps")
jade = require("gulp-jade")

paths =
  sass:
    source: ["./www/sass/**/*.scss"]
    dest: './www/css'
  coffee:
    source: ["./www/coffee/**/*.coffee"]
    dest: './www/js'
  templates:
    source: ["./www/jade/**/*.jade"]
    dest: './www/views'

gulp.task "default", ["sass", "coffee", "templates"]

gulp.task "templates", ->
  YOUR_LOCALS = {}

  gulp.src(paths.templates.source)
      .pipe(jade(locals: YOUR_LOCALS))
      .pipe(gulp.dest(paths.templates.dest))

gulp.task "coffee", (done) ->
  gulp.src(paths.coffee.source)
      .pipe(sourcemaps.init())
      .pipe(coffee(bare: true).on("error", gutil.log))
      .pipe(concat("application.js"))
      .pipe(sourcemaps.write())
      .pipe(gulp.dest(paths.coffee.dest))

gulp.task "sass", (done) ->
  gulp.src("./www/sass/application.scss")
      .pipe(sourcemaps.init())
      .pipe(sass())
      .pipe(sourcemaps.write())
      .pipe(gulp.dest(paths.sass.dest))
      .pipe(minifyCss(keepSpecialComments: 0))
      .pipe(rename(extname: ".min.css"))
      .pipe(gulp.dest(paths.sass.dest))

gulp.task "watch", ->
  gulp.watch(paths.sass.source, ["sass"])
  gulp.watch(paths.coffee.source, ["coffee"])
  gulp.watch(paths.templates.source, ["templates"])

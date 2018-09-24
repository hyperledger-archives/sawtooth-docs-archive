module.exports = function(grunt) {

	//Configuration
	grunt.initConfig({
  	sass: {
      dist: {
        options: {
          require: 'susy',
          includePaths: require('bourbon').includePaths
        },
        files: [{
          expand: true,
          cwd: 'styles/sass',
          src: ['**/*.scss'],
          dest: 'styles/css',
          ext: '.css'
        }]
      }
    },
  	watch: {
  		css: {
  		  files: ['styles/sass/**/*.scss'],
  		  tasks: ['sass'],
  		}
    }
  });

  //Load tasks
  grunt.loadNpmTasks('grunt-sass');
  grunt.loadNpmTasks('grunt-contrib-watch');

  //Define custom tasks
//   grunt.registerTask('build', ['copy']);

};
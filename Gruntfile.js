module.exports = function(grunt) {

    grunt.initConfig({
      git_changelog: {
        minimal: {
          options: {
            file: 'MyChangelog.md',
            app_name : 'Git changelog'
          }
        },
        extended: {
          options: {
            repo_url: 'https://github.com/rafinskipg/git-changelog',
            app_name : 'Git changelog extended',
            file : 'EXTENDEDCHANGELOG.md',
            grep_commits: '^fix|^feat|^docs|^refactor|^chore|BREAKING',
            debug: true,
            tag : false //False for commits since the beggining
          }
        },
        fromCertainTag: {
          options: {
            repo_url: 'https://github.com/rafinskipg/git-changelog',
            app_name : 'My project name',
            file : 'tags/certainTag.md',
            tag : 'v0.0.1'
          }
        }
      },
      watch: {
          coffee: {
              files: ['./scripts/*.coffee', 'node_modules/@(_)*/*.coffee'],
              tasks: ['coffee:compile']
          }
      },
      coffee: {
          compile: {
              files: [
                  {
                      cwd: './lib/_logger/',
                      src: ['index.coffee'],
                      dest: './lib/_logger/',
                      ext: '.js',
                      expand: true
                  },
                  {
                      cwd: './lib/_slack/',
                      src: ['index.coffee'],
                      dest: './lib/_slack/',
                      ext: '.js',
                      expand: true
                  }
              ]
          }
      }
    })

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('git-changelog');
  
  grunt.registerTask('default', ['coffee', 'watch']);
  
};
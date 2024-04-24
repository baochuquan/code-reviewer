module GitReviewer
    require 'claide'
    require 'gitreviewer/blame/blame-tree'
    require 'gitreviewer/blame/blame-builder'
    require 'gitreviewer/utils/analyzer'
    require 'gitreviewer/algorithm/myers'

    class Command < CLAide::Command
        self.abstract_command = false

        self.description = <<-DESC
            git-reviewer is a git plugin used to analyze who should review a Merge Request or Pull Request, and more details related to code modifications.
        DESC

        self.command = 'git-reviewer'

        def self.options
            [
                ['--init', 'Initialize the code review configuration file of the Git repository. It will generate a `gitreviewer.json` file if needed.'],
                ['--target', 'The target branch to be analyzed, which is the same as the target branch selected when creating a Merge Request or Pull Request.'],
                ['--source', 'Optional, if not specified, the default is the current branch pointed to by Git HEAD. The source branch to be analyzed, which is the same as the source branch selected when creating a Merge Request or Pull Request. '],
                ['--analyze-author', 'Only analyze relevant authors involved in code changes.'],
                ['--analyze-reviewer', 'Only analyze the proportion of code reviewers.'],
                ['--verbose', 'Show more details when executing commands.'],
                ['--version', 'Show version of git-reviewer.']
            ]
        end

        def initialize(argv)
            @init = argv.flag?('init', false)
            @target = argv.option('target')
            @source = argv.option('source')
            @analyze_reviewer = argv.flag?('reviewer', false)
            @analyze_author = argv.flag?('author', false)
            @verbose = argv.flag?('verbose', false)
            @version = argv.flag?('version', false)
            @help = argv.flag?('help', false)
            super
        end

        # def validate!
        #     super
        #     # 处理 help 选项
        #     if @help
        #         help!
        #         return
        #     end
        # end

        def run
            # 处理 help 选项
              if @help
                help!
                return
              end

            # 处理 version 选项
            if @version
                puts "git-reviewer #{GitReviewer::VERSION}"
                return
            end

            # 处理 init 选项
            if @init
                puts "init"
                return
            end

            # 分析
            if !@analyze_author && !@analyze_reviewer
                # 如果两个选项均没有，则默认分析作者和审查者
                @analyze_author = true
                @analyze_reviewer = true

                puts "analyze"
            end
        end
    end
end
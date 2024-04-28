module GitReviewer
  require 'claide'
  require 'gitreviewer/blame/blame-tree'
  require 'gitreviewer/blame/blame-builder'
  require 'gitreviewer/utils/analyzer'
  require 'gitreviewer/algorithm/myers'
  require 'gitreviewer/option/init_option'
  require 'gitreviewer/utils/checker'
  require 'gitreviewer/option/analyze_option'

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
    ].concat(super)
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
        initOption = InitOption.new
        initOption.execute
        return
      end

      # 分析
      analyze
    end

    def analyze
      # 检查环境
      if !Checker.isGitRepositoryExist?
        Printer.red "Error: git repository not exist. Please execute the command in the root director of a git repository."
        exit 1
      end
      # 检查参数
      if !@analyze_author && !@analyze_reviewer
        # 如果两个选项均没有，则默认分析作者和审查者
        @analyze_author = true
        @analyze_reviewer = true
      end
      # 设置默认分支
      if @source == nil
        # 默认 source 为当前分支
        @source = Checker.currentGitBranch
      end
      if @target == nil
        Printer.red "Error: target branch cannot be nil or empty. Please use `--target=<branch>` to specify the target branch."
        exit 1
      end

      # 检查分支
      if @source != nil && @target != nil
        # source 分支
        if !Checker.isGitBranchExist?(@source)
          Printer.red "Error: source branch `#{@source}` not exist."
          exit 1
        end
        # target 分支
        if !Checker.isGitBranchExist?(@target)
          Printer.red "Error: target branch `#{@target}` not exist."
          exit 1
        end
      end


      # 执行分析
      analyzeOption = AnalyzeOption.new(@source, @target, @analyze_author, @analyze_reviewer, @verbose)
      analyzeOption.execute
    end
  end
end

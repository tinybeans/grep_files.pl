#!/usr/bin/perl
# Copyright (c) Tomohiro Okuwaki. http://www.tinybeans.net/blog/

use strict;
use warnings;
use utf8;

# 複数のファイルの操作
my $dir = shift;
my $files = [];

print "==== Replaced files ======\n";

$files = get_files($dir, $files);
foreach my $file (@$files) {
    my $reg_start = quotemeta('<!-- [ TOPIC PATH ] -->');
    my $reg_end = quotemeta('<!-- [ /TOPIC PATH ] -->');
    my $reg_ins = quotemeta('<!-- [ COLUMN_OUTER ] -->');
    my $match_text = '';
    my $matching = 0;
    my @content = ();
    my $res = '';
    
    # ファイルの内容を取得して、抜き出す部分を $match_text に取り出し、残りは @content に入れる
    open(FILE, '<', $file) or die qq(Can't open file "$file": $!);
    while (my $line = <FILE>) {
        if (!$matching and $line =~ /$reg_start/) {
            $match_text = $line;
            $matching = 1;
        }
        elsif ($matching and $line =~ /$reg_end/) {
            $match_text .= $line;
            $matching = 0;
        }
        elsif ($matching) {
            $match_text .= $line;
        }
        else {
            push(@content, $line); 
        }
    }
#     print "\n\n$match_text\n\n";
    close(FILE);
    
    # @content から挿入ポイントに先ほど抜き出した部分を挿入する
    foreach my $line (@content) {
        if ($line =~ /$reg_ins/) {
            $line = $match_text . "\n" .  $line;
        }
        $res .= $line;
    }
    
    # 今度は上書きモードでファイルを開き、コンテンツを書き換える
    open(FILE, '>', $file) or die qq(Can't open file "$file": $!);
    print FILE "$res";
    close(FILE);
    print "$file\n";
}

exit();

sub get_files {
    my ($dir, $list_ref) = @_;
    my @files;

    opendir(DIR, $dir)
        or die qq("Can't open directory "$dir": $!);
    @files = readdir(DIR);
    closedir(DIR);

    foreach my $file (sort @files){
        next if($file =~ /^\.{1,2}$/);
        if (-d "$dir/$file") {
            get_files("$dir/$file", $list_ref);
        }
        else{
            push(@$list_ref, "$dir/$file") if ($file =~ /\.html$/);
        }
    }
	return $list_ref;
}

__END__

=head1 NAME

grep_files.pl

=head1 SYNOPSIS

perl grep_files.pl /TARGET_DIRECTORY_FULL_PATH > log.txt

=head1 DESCRIPTION

移動するブロックは複数行、挿入ポイントはピンポイントが前提です。

=cat

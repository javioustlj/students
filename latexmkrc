# -*- perl -*-
$pdf_mode = 5;
$xelatex = 'xelatex -interaction=nonstopmode -file-line-error -halt-on-error %O %S';

# `latexmk` (no args) from project root -> auto-build all src/**/*.tex
# Each PDF mirrors src/ structure under build/
if (-d 'src' && !$ENV{_LATEXMK_CHILD} && !grep { /\.tex$/i } @ARGV) {
    require File::Find;
    require File::Basename;

    my @texfiles;
    File::Find::find(sub {
        push @texfiles, $File::Find::name if /\.tex$/;
    }, 'src');

    if (@texfiles) {
        $ENV{_LATEXMK_CHILD} = 1;
        my $fail = 0;
        for my $tex (sort @texfiles) {
            (my $rel = $tex) =~ s{^src/}{};
            my $outdir = 'build/' . File::Basename::dirname($rel);
            system('mkdir', '-p', $outdir);
            print "\n==> latexmk $tex -> $outdir\n";
            system('latexmk', "-outdir=$outdir", $tex);
            $fail = 1 if $?;
        }
        exit($fail ? 1 : 0);
    }
}

1;

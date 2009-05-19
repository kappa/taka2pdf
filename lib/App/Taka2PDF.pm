package App::Taka2PDF;

use warnings;
use strict;

use 5.8;

use File::Slurp;
use Data::Dumper;
use PDF::API2;
use Encode;
use List::Util qw/max/;

use Slides::Takahashi;

=head1 NAME

App::Taka2PDF - Takahashi to PDF converter

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use App::Taka2PDF;

    my $foo = App::Taka2PDF->new();
    ...

=head1 FUNCTIONS

=head2 run

This is a I<modulino>, so C<run()> function is used to run the app.

=cut

my @Slide_Dim = (4 * 300, 3 * 300);
my @Slide_Pad = (20, 20);
my $Line_Spacing = 1.5;

sub parse {
    my $data = shift;

    my @slides_src = split(/^----\n/m, $data);
    my @slides;

    my ($title, $header);
    foreach my $slide (@slides_src) {
        push @slides, parse_slide($slide, \$title, \$header);
    }

    return \@slides;
}

sub parse_slide {
    my ($src, $title_ref, $header_ref) = @_;
    my $slide;

    foreach my $line (split /\n/, $src) {
        if    ($line =~ /^TITLE::(.*)$/) {
            $$title_ref = $1;
            next;
        }
        elsif ($line =~ /^HEADER::(.*)$/) {
            $$header_ref = $1;
            next;
        }
        else {
            push @{$slide->{lines}}, Takahashi::Slide::Line->parse($line);
        }
    }

    $slide->{title}  = $$title_ref  if $$title_ref;
    $slide->{header} = $$header_ref if $$header_ref;

    return $slide;
}

sub render_slide {
    my ($slide, $pdf, $style) = @_;

    my $ctx = $pdf->page->gfx;

    my ($font_size, $text_top);
    my @lines = @{$slide->{lines}};

    my $work_height = $Slide_Dim[1] - $Slide_Pad[1] * 2;

    my $width = max(map { $_->width_1($style) } @lines);
    $font_size = ($Slide_Dim[0] - $Slide_Pad[0] * 2) / $width;

    my $text_height = $font_size * (1 + $Line_Spacing * (@lines - 1));

    if ($text_height > $work_height) {
        $font_size = $work_height / (1 + $Line_Spacing * (@lines - 1));

        $text_height = $work_height;
    }

    print "----\n";
    print "DimH: $Slide_Dim[1]\nPadH: $Slide_Pad[1]\n";
    print "wH: $work_height\n";
    print "fS: $font_size\n";
    print "fS * LS: " . $font_size * $Line_Spacing . "\n";
    print "L: " . @lines . "\n";

    print "tH: $text_height\n";

    my $vert_spacer = ($work_height - $text_height) / 2;
    print "vS: $vert_spacer\n";

    $text_top = $Slide_Pad[1]
        + $vert_spacer
        + $text_height
        - $font_size;

    @{$style}{qw/line_spacing font_size/} = ($Line_Spacing, $font_size);

    $ctx->save;
    my $line_num = 0;
    foreach my $line (@lines) {
        print "tT[$line_num]: $text_top\n";

        $ctx->restore; $ctx->save;
        $ctx->transform(
            -translate => [$Slide_Pad[0], $text_top],
        );

        $line->render($ctx, $style);

        $text_top -= $font_size * $Line_Spacing * ++$line_num;
    }
}

sub run {
    my $src = read_file($ARGV[0], binmode => ':utf8');
    my $slides = parse($src);

    my $pdf = PDF::API2->new;
    $pdf->mediabox(@Slide_Dim);

    my $font    = $pdf->ttfont('/usr/share/fonts/truetype/msttcorefonts/Arial.ttf');
    my $font_em = $pdf->ttfont('/usr/share/fonts/truetype/msttcorefonts/Arial_Black.ttf');

    foreach my $slide (@$slides) {
        render_slide($slide, $pdf, {
            normal_font => $font,
            em_font     => $font_em,
        });
    }

    $pdf->saveas('file.pdf');
}

=head1 AUTHOR

Alex Kapranoff, C<< <alex at kapranoff.ru> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-app-taka2pdf at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-Taka2PDF>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::Taka2PDF


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-Taka2PDF>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-Taka2PDF>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-Taka2PDF>

=item * Search CPAN

L<http://search.cpan.org/dist/App-Taka2PDF>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Alex Kapranoff, all rights reserved.

This program is released under the following license: GPL


=cut

1; # End of App::Taka2PDF

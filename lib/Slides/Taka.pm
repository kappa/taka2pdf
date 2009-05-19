package Slides::Taka;
use strict;
use warnings;

use Carp;
use Encode;
use File::Slurp;
use Parse::RecDescent;

our $Taka_Grammar = <<'EOG';
{
    my ($title, $header) = ('', '');
}

presentation: <leftop: slide /^----\n/m slide>
    {
        $return = {
            slides => $item[1]
        }
    }

slide: special_line(s?) line_nl(s)
    {
        $return = {
            lines => $item[2],
            ($title  ? (title  => $title)  : ()),
            ($header ? (header => $header) : ()),
        }
    }

special_line: (title_line | header_line) "\n"

title_line: /(?m)^TITLE::/ /(?m).*/
    { $title = $item[2] }

header_line: /(?m)^HEADER::/ /(?m).*/
    { $header = $item[2] }

line_nl: line "\n"
    { $return = $item[1] }

line: ...!/(?m)^----$/ /(?m)^/ text /(?m)$/
    { $return = $item[3] }

text: block(s)

block: markup_inline_cont | markup_inline_el | markup_block | normal_text

normal_text: /[^[\n]+/
    {
        $return = {
            type => 'normal',
            text => $item[1],
        }
    }

markup_inline_cont: '[[' markup_type ':' /[^:\n]+/ ':' markup_type ']]'
    {
        $return = {
            type => $item[2],
            text => $item[4],
        }
    }

markup_type: 'EM' | 'PRE'

markup_inline_el: '[[' image ']]'
    { $return = $item[2] }

image: 'image' /\s+/ attr(s /\s+/)
    {
        $return => {
            type => $item[1],
            map { %$_ } @{$item[3]}
        }
    }

attr: /\w+/ '=' '"' /[^"\n]+/ '"'
    { $return = { $item[1] => $item[4] } }

markup_block: '[[' markup_block_type ':' /.+^:/ms markup_block_type ']]'
    {
        $return = {
            type => $item[2],
            text => $item[4],
        }
    }

markup_block_type: 'PRE'
EOG

$Parse::RecDescent::skip = '';
$::RD_TRACE = 1;

our $Parser = Parse::RecDescent->new($Taka_Grammar);

sub parse {
    $Parser->presentation(scalar read_file($_[0], binmode => ':utf8'))
        or croak "Cannot parse presentation in $_[0]\n";
}

1;

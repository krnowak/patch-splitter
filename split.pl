# LocationMarker is a representation of a line that describes a
# location of a chunk of changed code. These are lines in a patch that
# look like:
#
# @@ -81,6 +81,7 @@ sub DB_COLUMNS {
#
# The line contains line number and count before the change and after
# the change. It also may contain some context, which comes after
# second `@@`. Context is the first line that is before the chunk with
# no leading whitespace.
package LocationMarker;
  my $class = (ref ($type) or $type or 'LocationMarker');
  my $class = (ref ($type) or $type or 'LocationMarker');
  if ($line =~ /^@@\s+-(\d+)(?:,(\d+))?\s+\+(\d+)(?:,(\d+))?\s+@@(?:\s+(\S.*))?$/)
    unless (defined ($old_line_count))
    {
        $old_line_count = 1;
    }
    unless (defined ($new_line_count))
    {
        $new_line_count = 1;
    }

  my $class = (ref ($self) or $self or 'LocationMarker');
# Section describes the generated patch and its ancestor-descendant
# relation to other generated patches.
package Section;
  my $class = (ref ($type) or $type or 'Section');
# CodeLine is a representation of a single line of code in diff. It's
# the line in diff that starts with a single sigil (either +, - or
# space) and the rest of the line is the actual code.
package CodeLine;
  Plus => 0, # added line
  Minus => 1, # removed line
  Space => 2, # unchanged line
  Binary => 3  # binary line
  Plus () => '+',
  Minus () => '-',
  Space () => ' '
  '+' => Plus,
  '-' => Minus,
  ' ' => Space
  my $class = (ref ($type) or $type or 'CodeLine');
# CodeBase is a single chunk of changed code.
package CodeBase;
  my $class = (ref ($type) or $type or 'CodeBase');
  my $line = CodeLine->new ($sigil, $code_line);
# FinalCode is the final form of the single code chunk. It contains
# lines that already took the changes made in older generated patches
# into account.
package FinalCode;
use parent -norequire, qw(CodeBase);
  my $class = (ref ($type) or $type or 'FinalCode');
    if ($line->get_sigil () == CodeLine::Space)
  my $additions = LocationMarker->new_zero ();
  my $additions = LocationMarker->new_zero ();
    last if ($line->get_sigil () != CodeLine::Space);
    last if ($line->get_sigil () != CodeLine::Space);
# SectionCode is a code chunk taken verbatim from the annotated patch.
package SectionCode;
use parent -norequire, qw(CodeBase);
  my $class = (ref ($type) or $type or 'SectionCode');
# LocationCodeCluster is a single code chunk that is being split
# between multiple sections.
package LocationCodeCluster;
  my $class = (ref ($type) or $type or 'LocationCodeCluster');
# DiffHeader is a representation of lines that come before the
# description of actual changes in the file. These are lines that look
# like:
#
# diff --git a/.bzrignore.moved b/.bzrignore.moved
# new file mode 100644
# index 0000000..f852cf1
package DiffHeader;
  my $class = (ref ($type) or $type or 'DiffHeader');
# DiffBase is a base package for either textual or binary diffs.
package DiffBase;
  my $class = (ref ($type) or $type or 'DiffBase');
# TextDiff is a representation of a single diff of a text file.
package TextDiff;
use parent -norequire, qw(DiffBase);
  my $class = (ref ($type) or $type or 'TextDiff');
      my $final_code = FinalCode->new ($final_marker);
  my $final_inner_correction = LocationMarker->new_zero ();
  my %additions = map { $_->get_name () => LocationMarker->new_zero () } @{$sections_array};
    if ($sigil == CodeLine::Plus)
    elsif ($sigil == CodeLine::Minus)
    if ($sigil == CodeLine::Plus)
    elsif ($sigil == CodeLine::Minus)
    elsif ($sigil == CodeLine::Space)
  if ($sigil == CodeLine::Plus)
  elsif ($sigil == CodeLine::Minus)
  elsif ($sigil == CodeLine::Space)
    if ($sigil == CodeLine::Space or
        ($section->is_older_than ($current_section) and $sigil == CodeLine::Minus) or
        ($section->is_younger_than ($current_section) and $sigil == CodeLine::Plus))
      $self->_append_context ($before_context, CodeLine->new (CodeLine::Space, $current_line->get_line ()));
    if ($sigil == CodeLine::Space or
        ($section->is_older_than ($current_section) and $sigil == CodeLine::Minus) or
        ($section->is_younger_than ($current_section) and $sigil == CodeLine::Plus))
        $final_code->push_after_context_line (CodeLine->new (CodeLine::Space, $current_line->get_line ()));
  return map { CodeLine::get_char ($_->get_sigil ()) . $_->get_line () } @{$lines};
# BinaryDiff is a representation of a diff of a binary file.
package BinaryDiff;
use parent -norequire, qw(DiffBase);
  my $class = (ref ($type) or $type or 'BinaryDiff');
# Patch is a representation of the annotated patch.
package Patch;
  my $class = (ref ($type) or $type or 'Patch');
# ParseContext describes the current state of parsing the annotated
# patch.
package ParseContext;
  my $class = (ref ($type) or $type or 'ParseContext');
    'patch' => Patch->new (),
# GnomePatch looks like a mixed bag of code that includes parsing the
# annotated patch and generating the smaller patches from the
# annotated one.
package GnomePatch;
  my $class = (ref ($type) or $type or 'GnomePatch');
  $self->{'p_c'} = ParseContext->new ('intro', $ops);
  my $found_author = 0;
      if ($found_author)
      $found_author = 1;
      my $section = Section->new ($name, $description, scalar (@{$sections_array}));
    my $diff_header = DiffHeader->new ();
  my $diff = TextDiff->new ();
  my $initial_marker = LocationMarker->new ();
  my $last_cluster = LocationCodeCluster->new ($initial_marker);
        $code = SectionCode->new ($last);
      $code->push_line (CodeLine::Minus, '- ');
      my $marker = LocationMarker->new ();
      $last_cluster = LocationCodeCluster->new ($marker);
          $code = SectionCode->new ($section);
      my $type = CodeLine::get_type ($sigil);
        $code = SectionCode->new ($last);
    if ($line->get_sigil () != CodeLine::Space)
  my $diff = BinaryDiff->new ();
          $code = SectionCode->new ($sections_hash->{$name});
      $code = SectionCode->new ($sections_array->[-1]);
      $code->push_line (CodeLine::Binary, $line);
my $p = GnomePatch->new ();
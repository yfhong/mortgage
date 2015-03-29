#!/usr/bin/perl -w
# mortgage.pl --- Calculate mortgage payment
# Author: Hong Yifan (homer) <hyfing@gmail.com>
# Created: 29 Mar 2015
# Version: 0.01

use warnings;
use strict;
use POSIX;

my $fund_loan = 800000; ## 公积金贷款金额
my $commercial_loan = 1200000;  ## 商业贷款金额
my $month_pay_thresh = 15000;  ## 月供能力上限

my $month_in_year = 12;

## 利率
## 公积金贷款
my %fund_rate = (
    60 => 0.035, # 5年以内
    360 => 0.040, # 5年以上
);
## 商业贷款
my %commercial_rate = (
    12 => 0.0535, # 1年以内
    60 => 0.0575, # 5年以内
    360 => 0.059, # 5年以上
);

sub mortgage {
    ## 参数表
    my ($interest_rate, # 利率
        $loan, # 贷款金额
        $months # 贷款时间，以月表示
    ) = @_;
    ## 返回值
    my ($month_pay, # 月供
        $interest # 总利息
    );

    $month_pay = $loan * $interest_rate / ($month_in_year * (1 - (1 / (1 + $interest_rate/$month_in_year)) ** $months));

    $interest = $month_pay * $months - $loan;

    return ($month_pay, $interest);
};


## 全部结果暂存
my $all_results = [];

foreach my $fund_year ( 1 .. 30 ) {
    my $fund_rate = $fund_rate{360};
    $fund_rate = $fund_rate{60} if $fund_year <= 5;

    my ($fund_month_pay, $fund_interest) = mortgage( $fund_rate, $fund_loan, $fund_year * $month_in_year);

    foreach my $com_year ( 1 .. 30 ) {
        my $com_rate = $commercial_rate{360};
        $com_rate = $commercial_rate{60} if $com_year <= 5;
        $com_rate = $commercial_rate{12} if $com_year <= 1;

        my ($com_month_pay, $com_interest) = mortgage( $com_rate, $commercial_loan, $com_year * $month_in_year );

        my $month_pay = $fund_month_pay + $com_month_pay;
        my $total_interest = $fund_interest + $com_interest;

        push @{$all_results}, [$fund_year, $com_year, $month_pay, $total_interest];
    }
}


my @results = sort { $a->[3] <=> $b->[3] } map { $_->[2] < $month_pay_thresh ? $_ : () } @{$all_results};

printf("公积金贷款期,商业贷款期,月供金额,总利息支出,\n");

foreach ( @results ) {
    #    printf "公积金 %i 年，商贷 %i 年，月付 %.2f ，总利息 %.2f 。\n", $_->[0], $_->[1], $_->[2], $_->[3];
    printf "%d,%d,%.2f,%.2f,\n", $_->[0], $_->[1], $_->[2], $_->[3];
}


__END__

=head1 NAME

mortgage.pl - Describe the usage of script briefly

=head1 SYNOPSIS

mortgage.pl [options] args

      -opt --long      Option description

=head1 DESCRIPTION

Stub documentation for mortgage.pl,

=head1 AUTHOR

Hong Yifan (homer), E<lt>hyfing@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by Hong Yifan (homer)

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

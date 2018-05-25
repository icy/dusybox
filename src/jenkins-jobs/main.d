/*
  Purpose : Scan Jenkins jobs
  Author  : Ky-Anh Huynh
  License : MIT
  Date    : 2017-10-xx
*/

import std.stdio;
public import dusybox.jenkins.utils;

void main() {
  treeJenkinsJob("http://localhost:8080/", ["job/kyanh", "job/Lauxanh-PR-Review"]);
}

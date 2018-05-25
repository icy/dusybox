/*
  Purpose : Scan Jenkins jobs
  Author  : Ky-Anh Huynh
  License : MIT
  Date    : 2017-10-xx
*/

module dusybox.jenkins.utils;

import std.net.curl;
import std.json;
import std.stdio;
import std.algorithm.iteration;
import std.array;
import std.string;

/*
  Getting from function arguments
  Getting from environment
  Getting from file (if any)
*/
string[] getJenkinsAuthenticationFromEnv(in string envName = "JENKINS_TOKEN", in string envValue = null) {

  string token;
  if (envValue is null) {
    import std.process;
    token = std.process.environment.get(envName);
  }
  else {
    token = envValue;
  }

  if (token is null && envName == "JENKINS_TOKEN") {
    import std.file;
    import std.path;
    try {
      // FIXME: Use dotEnv instead.
      auto token_file = chainPath("~", ".jenkins.token").array.expandTilde;
      token = readText(token_file).strip();
      debug stderr.writefln(":: (debug) Reading JENKINS_TOKEN from file: %s", token_file);
    }
    catch (Exception exc){
      token = null;
    }
  }

  string[] result = null;
  auto atPosition = token.indexOf(':');
  if (atPosition > -1) {
    result ~= token[0 .. atPosition];
    result ~= token[atPosition + 1 .. $];
  }

  return result;
}

unittest {
  auto ret = getJenkinsAuthenticationFromEnv("NON_EXISTENT");
  assert(ret == null);

  ret = getJenkinsAuthenticationFromEnv("JENKINS_TOKEN", "user:pass");
  assert(ret && ret[0] == "user", "Username should be 'user'");
  assert(ret && ret[1] == "pass", "Password should be 'pass'");

  import core.sys.posix.stdlib;
  import std.string: toStringz;
  import std.conv;

  string jenkinsToken = "TEST_TOKEN=";
  putenv(cast(char*)jenkinsToken.toStringz);
  ret = getJenkinsAuthenticationFromEnv("TEST_TOKEN");
  assert(ret is null, "Unable to get TEST_TOKEN");

  jenkinsToken = "TEST_TOKEN=user:pass";
  putenv(cast(char*)(jenkinsToken.toStringz));
  ret = getJenkinsAuthenticationFromEnv("TEST_TOKEN");
  assert(ret && ret[0] == "user", "Username should be 'user'");
  assert(ret && ret[1] == "pass", "Password should be 'pass'");
}

// FIXME: Jenkins may return wrong output here...
JSONValue describeJenkinsJob(in string job_url) {
  auto client = HTTP();
  auto user_pass = getJenkinsAuthenticationFromEnv("JENKINS_TOKEN");
  if (user_pass !is null) {
    client.setAuthentication(user_pass[0], user_pass[1]);
  }
  auto content = get(job_url ~ "/api/json", client);
  auto ret = parseJSON(content);
  return ret;
}

unittest {
  auto ret = getJenkinsAuthenticationFromEnv("JENKINS_TOKEN");
  assert(ret !is null, "Please set JENKINS_TOKEN in your test environment");

  import std.exception;
  assertNotThrown(describeJenkinsJob("http://localhost:8080/job/Lauxanh-DevOps"), "jenkinsJob");
}

void displayJob(JSONValue job, in string[] exitPatterns = null, in uint level = 0) {
  if ("name" in job && "url" in job) {
    if (
      exitPatterns is null
      || exitPatterns.filter!(pat => job["url"].str.indexOf(pat) > -1).empty
    )
    {
      treeJenkinsJob(job["url"].str, exitPatterns, level + 1);
    }
  }
}

void treeJenkinsJob(in string start_url, in string[] exitPatterns = null, in uint level = 0) {
  auto jobs = describeJenkinsJob(start_url);

  if ("builds" in jobs
      && (("color" !in jobs) || (jobs["color"].str != "disabled"))
      && "url" in jobs
      && "lastCompletedBuild" in jobs
      && "lastSuccessfulBuild" in jobs
  )
  {
    auto url = jobs["url"].str;
    auto lastCompletedBuild = (!jobs["lastCompletedBuild"].isNull() && "number" in jobs["lastCompletedBuild"]) ? jobs["lastCompletedBuild"]["number"].integer : 0;
    auto lastSuccessfulBuild = (!jobs["lastSuccessfulBuild"].isNull() && "number" in jobs["lastSuccessfulBuild"]) ? jobs["lastSuccessfulBuild"]["number"].integer : 0;
    if (lastCompletedBuild) {
      auto lastBuildData = describeJenkinsJob(format("%s/%s", url, lastCompletedBuild));
      size_t timestamp = 0;
      if (!lastBuildData.isNull() && "timestamp" in lastBuildData) {
        timestamp = lastBuildData["timestamp"].integer;
      }

      auto lastStatus = (lastCompletedBuild == lastSuccessfulBuild) ? "SUCCESS" : "FAILED";
      import std.range : repeat;
      writefln("%-(%s%)%s %s %s %s", "| ".repeat(level), url, lastStatus, lastCompletedBuild, timestamp);
    }
  }
  if ("jobs" in jobs) {
    auto js = jobs["jobs"].array;
    js.each!(job => displayJob(job, exitPatterns, level));
  }
}

unittest {
  import std.exception;
  assertNotThrown(treeJenkinsJob("http://localhost:8080/job/Lauxanh-DevOps/", ["job/kyanh", "job/Lauxanh-PR-Review"]));
}

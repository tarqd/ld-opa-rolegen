package launchdarkly.customroles.utilities


parts(action) = x {
     x := regex.find_n("([a-z]+)|([A-Z][a-z]+)", action , -1)
}
verb(action) = x {
	x := parts(action)[0]
}
subject(action) = x {
	p := parts(action)
	x := concat("", array.slice(p, 1, count(p)))
}

project(key, tags) = x {
  x := with_tags(["proj", key], tags)
}
env(key, tags) = x {
  x := with_tags(["env", key], tags)
}
flag(key, tags) = x {
  x := with_tags(["env", key], tags)
}
with_tags(path, tags) = x {
  is_array(tags)
  x := array.concat(path, [tags])
}
with_tags(path, tags) = x {
  not is_array(tags)
  x := array.concat(path, [[tags]])
}
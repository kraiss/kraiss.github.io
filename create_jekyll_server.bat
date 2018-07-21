docker run -d -v C:/dev/code/github/kraiss.github.io/:/srv/jekyll -p 80:4000 --name=jekyll jekyll/jekyll jekyll serve
docker logs -f jekyll
# Vilicus Scan

<p align="left">
  <a href="https://github.com/edersonbrilhante/vilicus-github-action/releases"><img src="https://img.shields.io/github/v/release/edersonbrilhante/vilicus-github-action"/></a>
</p>

## Container scanning

Scan can be done using remote image and local image. 

For example using docker.io as remote repository the image will be `docker.io/your-organization/image:tag`:
```yaml
 - name: Scan image
   uses: edersonbrilhante/vilicus-github-action@main
   with:
     image: "docker.io/myorganization/myimage:tag"
```

And to use a local image its need to tag as `localhost:5000/image:tag`:
```yaml
 - name: Scan image
   uses: edersonbrilhante/vilicus-github-action@main
   with:
     image: "localhost:5000/myimage:latest"
```

## Action Inputs

| Input Name | Description | Default Value |
|-----------------|-------------|---------------|
| `image` | The image to scan | N/A |

## Example Workflows 

Complete example with steps for cleaning space, building local image, vilicus scanning and sending results for github security
```yaml
name: Container Image CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
        uses: actions/checkout@v2

      - name: Maximize Build Space
        uses: easimon/maximize-build-space@master
        with:
          root-reserve-mb: 512
          swap-size-mb: 1024
          remove-dotnet: 'true'
          remove-android: 'true'
          remove-haskell: 'true'

      - name: Build the Container image
        run: docker build -t localhost:5000/local-image:${GITHUB_SHA} . 
      
      - name: Vilicus Scan
        uses: edersonbrilhante/vilicus-github-action@main
        with:
          image: "localhost:5000/local-image:${GITHUB_SHA}"

      - name: Upload results to github security
        uses: github/codeql-action/upload-sarif@v1
        with:
          sarif_file: artifacts/results.sarif
```
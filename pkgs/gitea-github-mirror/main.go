package main

import (
	"code.gitea.io/sdk/gitea"
	"context"
	"errors"
	"log"
	"os"
)

import "github.com/google/go-github/v55/github"

func main() {
	err := sync()
	if err != nil {
		log.Fatalf("Failed to sync: %v", err)
		return
	}
}

func sync() error {
	githubToken := os.Getenv("GITHUB_TOKEN")
	if githubToken == "" {
		return errors.New("GITHUB_TOKEN is not set")
	}
	githubClient := github.NewClient(nil).WithAuthToken(githubToken)
	giteaToken := os.Getenv("GITEA_TOKEN")
	if giteaToken == "" {
		log.Fatalf("GITEA_TOKEN is not set")
		return errors.New("")
	}
	giteaClient, err := gitea.NewClient("http://sagittarius:3000", gitea.SetToken(giteaToken))
	if err != nil {
		log.Fatalf("Failed to init client: %v", err)
	}

	githubRepos, err := listGithubRepos(githubClient)
	if err != nil {
		log.Fatalf("Failed to list GitHub repos: %v", err)
	}
	log.Printf("githubRepos: %v", githubRepos)

	giteaRepos, err := listGiteaRepos(giteaClient)
	if err != nil {
		log.Fatalf("Failed to list Gitea repos: %v", err)
	}

	log.Printf("giteaRepos: %v", giteaRepos)

	for _, src := range githubRepos {
		mirror := giteaRepos[*src.Name]
		if mirror != nil {
			if !mirror.Mirror {
				log.Fatalf("Cannot mirror %s: already exists", *src.Name)
			}

			if mirror.Archived {
				_, _, err := giteaClient.EditRepo(
					mirror.Owner.UserName,
					mirror.Name,
					gitea.EditRepoOption{Archived: new(bool)},
				)
				if err != nil {
					log.Fatalf("Failed to edit %s: %v", *src.Name, err)
				}
			}
			continue
		}
		log.Printf("Mirroring %s", *src.Name)
		option := gitea.MigrateRepoOption{
			RepoName:  *src.Name,
			CloneAddr: *src.CloneURL,
			AuthToken: githubToken,
			Mirror:    true,
			Private:   true,
		}
		_, _, err := giteaClient.MigrateRepo(option)
		if err != nil {
			log.Fatalf("Failed to mirror %s: %v", *src.Name, err)
		}

	}
	return nil
}

func listGithubRepos(client *github.Client) (map[string]*github.Repository, error) {
	reposByName := make(map[string]*github.Repository)
	page := 0

	for {
		repos, response, err := client.Search.Repositories(
			context.Background(),
			"user:nathanregner",
			&github.SearchOptions{
				ListOptions: github.ListOptions{
					Page:    page,
					PerPage: 1000,
				},
			},
		)
		if err != nil {
			return nil, err
		}

		for _, repo := range repos.Repositories {
			reposByName[*repo.Name] = repo
		}

		page = response.NextPage
		if page == 0 {
			break
		}
	}

	return reposByName, nil
}

func listGiteaRepos(client *gitea.Client) (map[string]*gitea.Repository, error) {
	reposByName := make(map[string]*gitea.Repository)
	page := 0

	for {
		repos, _, err := client.ListMyRepos(gitea.ListReposOptions{ListOptions: gitea.ListOptions{
			Page: page,
		}})
		if err != nil {
			return nil, err
		}
		if len(repos) == 0 {
			break
		}
		for _, repo := range repos {
			reposByName[repo.Name] = repo
		}
		page += 1
	}

	return reposByName, nil
}

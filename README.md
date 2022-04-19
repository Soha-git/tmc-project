# Hello-Golang
Это проект был разработан, в рамках дипломного проекта по оканчанию курса в школе [TeachMeSkills](https://teachmeskills.by/).

Данный проект автоматизирует процесс сборки приложения, тестирования, установку необходимых компонентов для его работы и доставку рабочего приложения на целевую инфраструкту.

В качестве целевой инфраструктуры использовался: [Minikube](https://minikube.sigs.k8s.io/docs/start/)

В качестве приложения использовался проект https://github.com/hackersandslackers/golang-helloworld

---
## Структура проекта
```no-highlight
k8s/
  hello-golang/			    ---Helm-chart приложения
	templates/
		Deployment.yaml
		hpa.yaml
		Ingress.yaml
		Secret.yaml
		Service.yaml
		ServiceAccount.yaml
	Chart.yaml
	values.yaml

   monitoring/					
		alertmanager.yaml 	--- файл конфигурации уведомления мониторинга 

   script/
		minikube_install.sh --- скрипт установки minikube, kubectl, helm
		minikube_run.sh		--- скрипт запуска minikube, установка gitlab-runner

test/ 						--- тесты приложения 
   request_test.go
   server_test.go

.gitlab-ci.yaml	-- CI/CD pipeline
dockerfile
.ci-notify.sh  -- скрипт уведомления работы CI/CD pipeline
go.mod
go.sum
main.go 
renovate.json
```

## Установка и запуск 
---
Для работы с данным проектам необходим  [Minikube](https://minikube.sigs.k8s.io/docs/start/), [Kubeclt](https://kubernetes.io/ru/docs/tasks/tools/install-kubectl/) и [Helm](https://helm.sh/).

Чтобы установить данные компоненты,вы можете запустить скрипт **minikube_install.sh** расположенный в папке **k8s/script/**.
Либо воспользоватся офицальной документацией [Minikube](https://minikube.sigs.k8s.io/docs/start/), [Kubeclt](https://kubernetes.io/ru/docs/tasks/tools/install-kubectl/) и [Helm](https://helm.sh/).

Для запуска [Minikube](https://minikube.sigs.k8s.io/docs/start/) и нужных компонентов( установка [gitlab-runner](https://docs.gitlab.com/runner/)), необходимо запустить скрипт **minikube_run.sh** расположенный в папке **k8s/script/**.

```no-highlight
В скрипт minikube_run.sh необходимо передать либо изменить в нутри скрипта 3 переменные:

- gitlab_tags -- ваши названия тегов которые будет использовать gitlab-runner 
- gitlab_url --  по умолчанию https://gitlab.com/
- gitlab_token -- регистрационный token

Эти переменные необходимы для установки gitlab-runner
```
Значение **gitlab_url** и **gitlab_url** можно найти в настройках runners для этого перейдите в проект далее **Settings > CI/CD** и разверните раздел **Runners**.

---

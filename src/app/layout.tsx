export const metadata = { title: "OperaOS", description: "Gestão de ordens de serviço em campo" };

export default function RootLayout({ children }: { children: React.ReactNode }) {
  const preview = process.env.KADAI_DEPLOY_ENV === "preview";
  return (
    <html lang="pt-BR">
      <body style={{ fontFamily: "system-ui, sans-serif", margin: 0 }}>
        {preview && (
          <div style={{ background: "#f59e0b", padding: 6, textAlign: "center", fontSize: 13 }}>
            Ambiente de testes · {process.env.NEXT_PUBLIC_APP_VERSION}
          </div>
        )}
        {children}
      </body>
    </html>
  );
}
